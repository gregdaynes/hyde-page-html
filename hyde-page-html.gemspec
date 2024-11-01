require File.expand_path("./lib/hyde-page-html.rb")

Gem::Specification.new do |s|
  s.name = "hyde-page-html"
  s.version = Hyde::Page::Html::VERSION
  s.summary = "Plugin for jekyll to validate, tidy and minify HTML files for separate pages."
  s.description = "Plugin for jekyll to validate, tidy and minify HTML files for separate pages."
  s.authors = ["Gregory Daynes"]
  s.email = "email@gregdaynes.com"
  s.homepage = "https://github.com/gregdaynes/hyde-page-html"
  s.license = "MIT"

  s.files = Dir["{lib}/**/*.rb"]
  s.require_path = "lib"

  s.add_development_dependency "jekyll", ">= 4.0", "< 5.0"
  s.add_dependency 'w3c_validators', '~> 1.3', '>= 1.3.7'
  s.add_dependency 'htmlbeautifier', '~> 1.4', '>= 1.4.3'
  s.add_dependency 'htmlcompressor', '~> 0.4.0'
end
