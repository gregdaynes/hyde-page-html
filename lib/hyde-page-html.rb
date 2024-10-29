require "jekyll"
require "digest"
require 'w3c_validators'

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

      # use the cache to track 1 page or document per build
      return doc.output if cache.key?('checked')

      # check page is in cache and valid
      if cache.key?(doc.path)
        # return doc.output if self.cache[doc.path] == 1
      end

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
        "validator_uri" => nil
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
        return @page if @config.fetch('enable')

        if @config.fetch('validate')
          validate
        end

        return @page
      end

      private

      def validate
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

        @doc.output
      end

      def fetch_config
        @@config.merge(@site.config.fetch("hyde_page_html", {}))
      end
    end
  end
end
