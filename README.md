ScrDoc
======

[![StyLua.Check](https://github.com/MasWag/scrdoc/actions/workflows/stylua.yml/badge.svg?branch=master)](https://github.com/MasWag/scrdoc/actions/workflows/stylua.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](./LICENSE)

This is a custom reader of Pandoc that extracts documentation from comments in a script file. This reader is primarily for shell scripts but can also be used for script languages using `#` for comments.

Prerequisites
-------------

- Pandoc >= 2.16.2

Usage
-----

The usage of this reader is as follows.

```
pandoc -f ./scrdoc.lua -i [InputFile] -o [OutputFile]
```

A concrete example of how to generate roff man is as follows:

```sh
pandoc -s -f ./scrdoc.lua -i ./examples/example.sh -t man -o example.0 -V title:'example' -V section:0 -V header:'ScrDoc Example' -V footer:'ScrDoc'
```

Similarly, you can generate a markdown file as follows:

```sh
pandoc -s -f ./scrdoc.lua -i ./examples/example.sh -o example.md
```

Markup
------

ScrDoc reads the header comments of a script file. Namely, it only read the comments at the beginning of the file (possibly following the shebang line). All the contents after the first non-comment line are ignored.

- Lines starting with `# ` (sharp plus one space) are considered as the header (of level 1) of the documentation.
- Lines starting with `#  ` (sharp plus two spaces) are considered as the normal text.
- Lines starting with `#  *` (sharp plus two spaces and asterisk) are considered as the bullet list.
- Lines starting with `#  #` (sharp plus two spaces and hash) are considered as the ordered list.
- Lines starting with `#` (sharp) but not followed by a space are ignored.
