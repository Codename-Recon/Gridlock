# Gridlock types

This is a shared repo for client and server to use for the definition of different data types.

## Validation

Validation can be run through anything that supports json schema, supported implementations can be [found here](https://json-schema.org/implementations). I have included a [CLI tool](https://github.com/neilpa/yajsv) to be part of the repo for now until we implement some sort of CI pipeline for validation. To install you only need to install the CLI tool:

```bash
$ go install github.com/neilpa/yajsv
$ ./validate.sh
```
