#!/bin/bash -l

if [[ $DEBUG_MODE -eq 1 ]]; then
  echo
  echo "     +INPUT_VERSION=$INPUT_VERSION"
  echo "     +INPUT_DIRECTORY=$INPUT_DIRECTORY"
  echo "     +INPUT_PATTERN=$INPUT_PATTERN"
  echo "     +INPUT_STYLE=$INPUT_STYLE"
  echo "     +INPUT_FALLBACK=$INPUT_FALLBACK"
  echo "     +INPUT_FAIL_ON_ERROR=$INPUT_FAIL_ON_ERROR"
  echo
fi

# Split the file pattern string obtaining an array
readarray -t INPUT_PATTERN_ARRAY < <(echo -e $INPUT_PATTERN)

# Create multiple -p PATTERN options allowing to use in yaml:
# pattern: |
#   *.h
#   *.hh
#   *.cpp
for p in ${INPUT_PATTERN_ARRAY[@]} ; do
  pattern_cmd_option="$pattern_cmd_option -p $p "
done

# Call the style check script
check_clang_format_compliance \
  -v "$INPUT_VERSION" \
  -d "$INPUT_DIRECTORY" \
  -s "$INPUT_STYLE" \
  -f "$INPUT_FALLBACK" \
  $pattern_cmd_option

# Catch the exit status
exit_status=$?

# Get the diff and fix escape special characters
# https://github.community/t/set-output-truncates-multiline-strings/16852
diff=$(</tmp/style_diff.txt)
diff="${diff//'%'/'%25'}"
diff="${diff//$'\n'/'%0A'}"
diff="${diff//$'\r'/'%0D'}"

# Store the diff in an output variable
echo "::set-output name=diff::$diff"

# Propagate the exit status
if [[ $INPUT_FAIL_ON_ERROR -eq 1 ]] ; then
  exit $exit_status
else
  exit 0
fi
