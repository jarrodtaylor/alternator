## <!-- @header -->

Run `alternator --help` for a quick reference.

```bash
$ alternator --help

OVERVIEW: Alternator builds simple, static sites.

Visit https://jarrodtaylor.github.io/alternator to learn more.

USAGE: alternator [<source>] [<target>] [--port <port>]

ARGUMENTS:
  <source>                Path to your source directory. (default: .)
  <target>                Path to your target directory. (default: <source>/_build)

OPTIONS:
  -p, --port <port>       Port for the localhost server.
  --version               Show the version.
  -h, --help              Show help information.
```

Alternator uses the files from `<source>` to build your site into `<target>`.

```bash
$ alternator path/to/source path/to/publish
```

`<source>` can be anything you want &mdash; Alternator doesn't care about project
structure and doesn't come with any code generators.

Optionally, you can give Alternator a `--port` and it'll rebuild `<source>`
after each change and make `<target>` available on localhost at the specified port.

```bash
$ alternator path/to/source path/to/publish --port 8080
[watch] watching path/to/source for changes
[serve] serving path/to/publish on http://localhost:8080
^c to stop
```
