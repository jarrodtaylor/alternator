## <!-- @header -->

Each time Alternator runs, it looks at everything in `<source>` and builds any
file that's been added or modified since the last run.

### Ignoring Files

Append a `!` to a filename and Alternator _not_ move it to `<target>`.

For example, `path/to/source/!layout.html` can be used as a layout
without being copied to `path/to/publish/!layout.html`.

### Copying Assets

Files that don't need to be processed, such as assets,
are copied as-is to `<target>`.

### Pruning `<target>`

After building, Alternator will check for any files or folders in `<target>`
that have been removed from `<source>` and delete them.
