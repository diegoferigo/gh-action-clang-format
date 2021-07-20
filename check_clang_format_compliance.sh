#!/bin/bash -l

# =======================
# Variables and functions
# =======================

BRed='\e[1;31m'
BBlue='\e[1;34m'
BGreen='\e[1;32m'
ColorOff='\e[0m'

function msg() {
  echo -e "$BGreen==>$ColorOff $@"
}

function msg2() {
  echo -e "  $BBlue->$ColorOff $@"
}

function err() {
  echo -e "$BRed==>$ColorOff $@" >&2
}

function debug() {
  if [[ $DEBUG_MODE -eq 1 ]] ; then
    echo "+$@"
  fi
}

function print_help() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo ""
  echo "-h, --help         display this help and exit."
  echo "-v, --version      select the clang-format version (6.0, 7, 8, ..., 13)."
  echo "-d, --directory    select the directory where to find the files to format."
  echo "-p, --pattern      add a find pattern entry (it could be used multiple times)."
  echo "-s, --style        the clang-format style to apply."
  echo "-f, --fallback     the fallback clang-format style to apply (default: none)."
  echo "--debug            run the script in debug mode."
}

# ===================
# Commandline parsing
# ===================

debug "$@"

# Short options
SHORT_OPTS="hv:p:d:s:f:"

# Long options
LONG_OPTS="help,version:,pattern:,directory:,style:,fallback:,debug,"

OPTS=$(getopt \
  --options $SHORT_OPTS \
  --longoptions $LONG_OPTS \
  --name $(basename "$0") \
  -- $@)

eval set -- "$OPTS"

# Default values
DEBUG_MODE=${DEBUG_MODE:-0}
CLANG_VERSION=13
CLANG_STYLE=""
CLANG_FALLBACK_STYLE="none"
SOURCE_DIRECTORY=""
FILE_PATTERNS=()

while [ $# -gt 0 ]; do

  case "$1" in
    -h | --help)
      print_help
      exit 0
      ;;
    -v | --version)
      debug "Using clang-format version: $2"
      CLANG_VERSION=$2
      shift 2
      ;;
    -p | --pattern)
      debug "Adding new pattern: $2"
      FILE_PATTERNS+=($2)
      shift 2
      ;;
    -d | --directory)
      debug "Using source directory: $2"
      SOURCE_DIRECTORY=$2
      shift 2
      ;;
    -s | --style)
      debug "Using clang-format style: $2"
      CLANG_STYLE=$2
      shift 2
      ;;
    -f | --fallback)
      debug "Using clang-format fallback style: $2"
      CLANG_FALLBACK_STYLE=$2
      shift 2
      ;;
    --debug)
      debug "Enabling debug mode"
      DEBUG_MODE=1
      shift 1
      ;;
    --)
      shift
      break
      ;;
    *)
      err "Unrecognized option '$1'"
      exit 1
      ;;
  esac
done

if [[ ! -d $SOURCE_DIRECTORY ]] ; then
  err "Source directory does not exist: $SOURCE_DIRECTORY"
  exit 1
fi

if [[ -z $CLANG_STYLE ]] ; then
  err "Failed to read the --style option"
  exit 1
fi

debug "FILE_PATTERNS=$FILE_PATTERNS"
debug "{FILE_PATTERNS[@]}=${FILE_PATTERNS[@]}"

msg "Filtering files matching:"
for p in ${FILE_PATTERNS[@]}; do
  msg2 "$p"
done

# ===========
# Check tools
# ===========

if [[ -z $(type -t git) ]] ; then
  err "Failed to find command: git"
  exit 1
fi

if [[ -z $(type -t find) ]] ; then
  err "Failed to find command: find"
  exit 1
fi

if [[ -z $(type -t clang-format-$CLANG_VERSION) ]] ; then
  err "Failed to find command: clang-format-$CLANG_VERSION" >&2
  exit 1
fi

# ============
# Format files
# ============

# Here the build the file filter for 'find' in the form:
# -name PATTERN1 -or -name PATTERN2 -or -name PATTERN3 [...]

# Add the first pattern
find_cmd_options="-name ${FILE_PATTERNS[0]}"

# Get the number of patterns
num_of_patterns=${#FILE_PATTERNS[@]}

# Add the remaining patterns
for pattern in ${FILE_PATTERNS[@]:1:$(($num_of_patterns - 1))}; do
  find_cmd_options="$find_cmd_options -or -name $pattern"
done

debug "find_cmd_options=$find_cmd_options"
echo ""

msg "Running clang-format on the sources:"
msg2 "style: $CLANG_STYLE"
msg2 "fallback: $CLANG_FALLBACK_STYLE"
echo ""

# Run clang-format
find $SOURCE_DIRECTORY \
  -type f \( $find_cmd_options \) \
  -exec \
    clang-format-$CLANG_VERSION \
      --verbose \
      --style=$CLANG_STYLE \
      --fallback-style=$CLANG_FALLBACK_STYLE \
      -i \
  {} \;

echo ""

msg "Checking the resulting git diff"
pushd $SOURCE_DIRECTORY >/dev/null
git --no-pager diff --patch --minimal --output /tmp/style_diff.txt
popd >/dev/null

if [[ $(cat /tmp/style_diff.txt | wc -l) -eq 0 ]]; then
  msg "No style changes detected."
  exit 0
fi

# Return 1 if the folder contains unformatted files
err "The project is not compliant with the style."
exit 1
