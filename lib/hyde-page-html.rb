require "jekyll"
require "digest"
require 'w3c_validators'
require 'htmlbeautifier'
require 'htmlcompressor'

Jekyll::Hooks.register :site, :post_write do
  Hyde::Page.cache_delete('checked')
end

Jekyll::Hooks.register :pages, :post_render do |page|
  page.output = Hyde::Page.handler(page)
end

Jekyll::Hooks.register :documents, :post_render do |document|
  document.output = Hyde::Page.handler(document)
end

module Hyde
  module Page
    def self.cache
      Jekyll::Cache.new('HydePageHtml')
    end

    def self.cache_delete(key)
      return unless cache.key?(key)

      cache.delete(key)
    end

    def self.handler(doc)
      # filter out non-html pages
      return doc.output unless doc.output_ext == '.html'

      Hyde::Page::Html.new(doc, cache).run
    end

    class Html
      VERSION = "0.1.0"
    end

    class Html 
      include W3CValidators

      @@config = {
        "enable" => true,
        "validate" => true,
        "validator_uri" => nil,
        "beautify" => true,
        "minify" => true
      }

      def initialize(page, cache)
        @page = page
        @site = page.site
        @cache = cache
        @config = fetch_config

        @validator = W3CValidators::NuValidator.new({
          # running with docker locally docker run -it --rm -p 8888:8888 ghcr.io/validator/validator:latest
          validator_uri: @config.fetch('validator_uri')
        })
      end

      def run
        return @page.output unless @config.fetch('enable')

        output = @page.output

        if @config.fetch('validate')
          validate
        end

        if @config.fetch('beautify')
          output = beautify
        end

        if @config.fetch('minify')
          output = minify
        end

        @page.output = output
      end

      private

      def beautify
        Jekyll.logger.info('Beautifying HTML:', @page.path)
        HtmlBeautifier.beautify(@page.output, indent: "\t")
      end

      def minify
        Jekyll.logger.info('Minifying HTML:', @page.path)
        options = {
          :enabled => true,
          :remove_spaces_inside_tags => true,
          :remove_multi_spaces => true,
          :remove_comments => true,
          :remove_intertag_spaces => true,
          :remove_quotes => true,
          :compress_css => false,
          :compress_javascript => false,
          :simple_doctype => true,
          :remove_script_attributes => true,
          :remove_style_attributes => true,
          :remove_link_attributes => false,
          :remove_form_attributes => false,
          :remove_input_attributes => false,
          :remove_javascript_protocol => true,
          :remove_http_protocol => true,
          :remove_https_protocol => true,
          :preserve_line_breaks => false,
          :simple_boolean_attributes => true,
          :compress_js_templates => false
        }
        compressor = HtmlCompressor::Compressor.new(options)
        compressor.compress(@page.output)
      end

      def validate
        # use the cache to track 1 page or document per build when using public validator
        return if @cache.key?('checked')

        # check page is in cache and valid
        if @cache.key?(@page.path)
          # TODO clear cache when page changes?
          return @page.output if @cache[@page.path] == 1
        end

        Jekyll.logger.info('Validating HTML:', @page.path)
        results = @validator.validate_text(@page.output)

        if @config.fetch('validator_uri').nil?
          @cache['checked'] = true
        end

        if results.errors.length.positive?
          errors = results.errors.reject { |err| err.to_s.include? 'CSS:' }

          if errors.length.positive?
            @cache[@page.path] = 0
          else
            @cache[@page.path] = 1
            return
          end

          errors.each do |err|
            msg = err.to_s.split(';')[1]
            line, error, reason = msg.split(': ')
            Jekyll.logger.error('', line.strip)
            Jekyll.logger.error('', reason.strip)
            Jekyll.logger.error('', "> #{error.strip}")
            Jekyll.logger.error('')
          end

          Jekyll.logger.info('Validated HTML:', 'errors found')
        else
          @cache[@page.path] = 1
          Jekyll.logger.info('Validated HTML:', 'valid')
        end
      end

      def fetch_config
        @@config.merge(@site.config.fetch("hyde_page_html", {}))
      end
    end
  end
end
