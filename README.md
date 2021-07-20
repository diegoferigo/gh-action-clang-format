# GitHub Action: clang-format

**This action runs `clang-format` on your sources and validates the style.**

The style can either be one of the [default profiles][style_options], 
or a customized `.clang-format` file part of the repository.

[style_options]: https://clang.llvm.org/docs/ClangFormatStyleOptions.html#configurable-format-style-options

## Getting started

Here below a simple example to validate pull request against the `Google` style:

```yaml
name: C++ Style

on:
  pull_request:
  workflow_dispatch:

jobs:

  clang-format-check:

    name: "Test C++ style"
    runs-on: ubuntu-latest

    steps:

      - name: "🔀 Checkout repository"
        uses: actions/checkout@v2

      - name: "⬇️️ Install dependencies"
        run: sudo apt-get install -y --no-install-recommends colordiff

      - name: "📝 Format C++"
        uses: diegoferigo/gh-action-clang-format@main
        id: format
        with:
          style: Google

      - name: "🔍️ Inspect style diff"
        if: failure()
        run: printf "${{ steps.format.outputs.diff }}" | colordiff
```

Have a look to [`ci.yml`][ci.yml] for a practical example, 
and refer to the input and output details below.

[ci.yml]: .github/workflows/ci.yml

## Inputs

| Name | Required | Default value | Description |
| ---- | -------- | ------------- | ----------- |
| `version` | No | `13` | the clang-format version to run |
| `directory` | No | `/github/workspace` | the directory where to find the files to format |
| `pattern` | No | `*.h *.hh *.cpp *.cc` | string defining the sources matching pattern |
| `style` | Yes | `-` | the clang-format style to apply |
| `fallback` | No | `none` | the fallback clang-format style to apply |
| `fail_on_error` | No | `1` | make the step fail in case of unformatted sources |

## Outputs

| Name | Description |
| ---- | ----------- |
| `diff` | The diff after the style formatting |

## Contributing

Pull requests are welcome. 
For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)
