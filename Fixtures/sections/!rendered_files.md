## <!-- @header -->

`.css`, `.htm`, `.html`, `.js`, `.md`, `.rss`, `.svg`, and `.xml`
files are rendered before being copied to `target`.

Rendering will expand includes, replace variables with their values,
wrap content layouts, and convert markdown to HTML.

### Metadata and Variables

Metadata is defined at the top of files as key/value pairs between `---` lines.

Any metadata prefixed with `@` is considered a variable and can be used inside
code comments.

```html
---
@title: Hello, world!
---
<html>
  <head>
    <title><!-- @title --></title>
  </head>
</html>
```

...renders as:

```html
<html>
  <head>
    <title>Hello, world!</title>
  </head>
</html>
```

Each type of file uses its native comment syntax.

`<!-- @foo -->`, `/* @foo */`, and `∕∕ @foo` all work.

Variables can define fallback values using `??`.
In this example, `@title` is defined while `@foo` is not.

```html
---
@title: Hello, world!
---
<html>
  <head>
    <title><!-- @title ?? My Webpage --></title>
  </head>
  <body>
    <!-- @foo ?? bar -->
  </body>
</html>
```

...renders as:

```html
<html>
  <head>
    <title>Hello, world!</title>
  </head>
  <body>
    bar
  </body>
</html>
```

### Layouts

A file can use the `#layout` macro in its metadata
to point to the layout file it will be rendered into.

A layout file uses the `#content` macro
to define where its included file is rendered.

Variables defined in the included file's metadata
will override those defined in layouts.

For example, an about page `path/to/source/about.html`:

```html
---
#layout: !design.html
@title: About Me
---
<p>This is an about page.</p>
```

...will be rendered inside `path/to/source/!design.html`:

```html
<html>
  <head>
    <title><!-- @title ?? My Website --></title>
  </head>
  <body>
    <!-- #content -->
  </body>
</html>
```

...to create `target/about.html`:

```html
<html>
  <head>
    <title>About Me</title>
  </head>
  <body>
    <p>This is an about page.</p>
  </body>
</html>
```

### Includes

Files can be included in other files with the `#include` macro.

Using the following `path/to/source/blog.html`:

```html
<html>
  <body>
    <!-- #include posts/!one.md -->
    <!-- #include posts/!two.md -->
  </body>
</html>
```

...with `posts/!one.md` and `posts/!two.md`
(notice the `!` in the filenames &mdash; `one.md` and `two.md` will not be copied to `target`):

```md
## Post One

This is the first post.
```

```md
## Post Two

This is the second post.
```

...will render `target/blog.html` as:

```html
<html>
  <body>
    <h2>Post One</h2>
    <p>This is the first post.</p>
    <h2>Post Two</h2>
    <p>This is the second post.</p>
  </body>
</html>
```

The  `#include` macro can pass variables to included files using `++`.

These variables will override those set in the included file's metadata.

For example, a generic blog post file `path/to/source/posts/!generic.md`:

```md
## <!-- @name -->

<!-- @content ?? This is some generic content. -->
```

...can be included in `path/to/source/blog.html` multiple times with different
variable values:

```html
<html>
  <body>
    <!-- #include posts/!generic.md ++ @name: My Blog Post -->
    <!-- #include posts/!generic.md ++ @name: My Other Post ++ @content: Some new content. -->
  </body>
</html>
```

...to create a `path/to/publish/blog.html`:

```html
<html>
  <body>
    <h2>My Blog Post</h2>
    <p>This is some generic content.</p>
    <h2>My Other Post</h2>
    <p>Some new content.</p>
  </body>
</html>
```

A file being included with the `#include` macro will not use a layout
even if one is defined in its metadata.
To force a nested layout, add `#forceLayout: true` to the included file's
metadata or pass it in as part of the `#include` syntax of the including file.
