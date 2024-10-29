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
  validator_uri: nil
  tidy: true
  minify: false
```

`enable`
: When true, the plugin will run through enabled processes

`validate`
: When true, checks the rendered HTML of each page and document against Nu Validator. If using the public checker, this is limited to 1 file per build.

`validator_uri`
: Url for a private validation service. Eg: local dockerized Nu Validator 'http://0.0.0.0:8888/'
: Run docker container with `docker run -it --rm -p 8888:8888 ghcr.io/validator/validator:latest`

`tidy`
: When true, pass the rendered html through htmlbeautifier 

`minify`
: When true, pass the rendered html through htmlcompressor
