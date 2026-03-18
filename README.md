ScrDoc
======

[![StyLua.Check](https://github.com/MasWag/scrdoc/actions/workflows/stylua.yml/badge.svg?branch=master)](https://github.com/MasWag/scrdoc/actions/workflows/stylua.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](./LICENSE)

This is a custom reader of Pandoc that extracts documentation from comments in a script file. This reader is primarily for shell scripts but can also be used for script languages using `#` comments by default or `//` and `--` comments with extensions.

Prerequisites
-------------

- Pandoc >= 3.0.1

Usage
-----

The default usage of this reader is as follows.

```
pandoc -f ./scrdoc.lua -i [InputFile] -o [OutputFile]
```

To read `//` comments instead, turn on the `slash_comments` extension.

```sh
pandoc -f ./scrdoc.lua+slash_comments -i [InputFile] -o [OutputFile]
```

To read Lua-style `--` comments instead, turn on the `lua_comments` extension.

```sh
pandoc -f ./scrdoc.lua+lua_comments -i [InputFile] -o [OutputFile]
```

Enable at most one of `slash_comments` or `lua_comments` at a time.

A concrete example of how to generate roff man is as follows:

```sh
pandoc -s -f ./scrdoc.lua -i ./examples/example.sh -t man -o example.0 -V title:'example' -V section:0 -V header:'ScrDoc Example' -V footer:'ScrDoc'
```

Similarly, you can generate a markdown file as follows:

```sh
pandoc -s -f ./scrdoc.lua -i ./examples/example.sh -o example.md
```

For languages using `//` comments, use the bundled JavaScript example.

```sh
pandoc -s -f ./scrdoc.lua+slash_comments -i ./examples/example.js -o example.js.md
```

For languages using Lua-style `--` comments, use the bundled Lua example.

```sh
pandoc -s -f ./scrdoc.lua+lua_comments -i ./examples/example.lua -o example.lua.md
```

Markup
------

ScrDoc reads the header comments of a script file. Namely, it only reads the comments at the beginning of the file (possibly following the shebang line). All the contents after the first non-comment line are ignored.

By default, ScrDoc reads comments starting with `#`.

- Lines starting with `# ` (sharp plus one space) are considered as the header (of level 1) of the documentation.
- Lines starting with `#  ` (sharp plus two spaces) are considered as the normal text.
- Lines starting with `#  *` (sharp plus two spaces and asterisk) are considered as the bullet list.
- Lines starting with `#  #` (sharp plus two spaces and hash) are considered as the ordered list.
- Lines starting with `#` (sharp) but not followed by a space are ignored.

With `pandoc -f ./scrdoc.lua+slash_comments`, the same rules apply to comments starting with `//`.
Ordered lists still use `#` inside the documentation body, so ordered list items start with `//  #`.

- Lines starting with `// ` (slash slash plus one space) are considered as the header (of level 1) of the documentation.
- Lines starting with `//  ` (slash slash plus two spaces) are considered as the normal text.
- Lines starting with `//  *` (slash slash plus two spaces and asterisk) are considered as the bullet list.
- Lines starting with `//  #` (slash slash plus two spaces and hash) are considered as the ordered list.
- Lines starting with `//` (slash slash) but not followed by a space are ignored.

With `pandoc -f ./scrdoc.lua+lua_comments`, the same rules apply to comments starting with `--`.
Ordered lists still use `#` inside the documentation body, so ordered list items start with `--  #`.

- Lines starting with `-- ` (dash dash plus one space) are considered as the header (of level 1) of the documentation.
- Lines starting with `--  ` (dash dash plus two spaces) are considered as the normal text.
- Lines starting with `--  *` (dash dash plus two spaces and asterisk) are considered as the bullet list.
- Lines starting with `--  #` (dash dash plus two spaces and hash) are considered as the ordered list.
- Lines starting with `--` (dash dash) but not followed by a space are ignored.
