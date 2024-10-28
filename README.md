Hyde Page HTML
=============

A Jekyll 4 plugin that enables validating, tidying and minfying generated HTML files.


Installation
------------

1. Add Hyde Page HTML to your Gemfile

`gem 'hyde-page-html', '~> 0.1.0'`

2. Add entry to your Jekyll config under plugins

```yaml
plugins:
  - hyde-page-html
  ...
```


Configuration
-------------

Hyde Page HTML comes with the following configuration. Override as necessary in your Jekyll Config

```yaml
hyde_page_html:
  enable: true
  validate: true
  tidy: true
  minify: false
```

`enable`
:  

`validate`
:

`tidy`
:

`minify`
: minify the css generated (reuses Jekyll's SASS compiler, so you can also use SASS/SCSS in your files)
