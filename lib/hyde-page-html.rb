require "jekyll"
require "digest"
require 'w3c_validators'

include W3CValidators

# TODO implement a rate limiting mechanism to not spam the W3C validator with
# every build request. 
skip_page_from_previous_error = 0
skip_document_from_previous_error = 0

Jekyll::Hooks.register :pages, :post_render do |page|
  # filter out non-html pages
  next unless page.output_ext == '.html'
  next unless skip_page_from_previous_error == 0
  page.output = Hyde::Page::RenderedHtml.new(page).output
end

Jekyll::Hooks.register :documents, :post_render do |document|
  # puts "Document rendered: #{page.url}"

  next unless document.output_ext == '.html'
  next unless skip_document_from_previous_error == 0
  document.output = Hyde::Page::RenderedHtml.new(document).output
end

module Hyde
  module Page
    class Html
      VERSION = "0.1.0"
    end

    class RenderedHtml < Jekyll::Document
      def initialize(doc)
        @doc = doc
        @validator = W3CValidators::NuValidator.new({
          :out => 'json',
          :parser => 'html5'
        })
      end

      def output
        results = @validator.validate_text(@doc.output)

        if results.errors.length > 0
          results.errors.each do |err|
            next if err.to_s.include? 'CSS:'

            if @doc.instance_of? Jekyll::Page
              skip_page_from_previous_error = 1
            elsif @doc.instance_of? Jekyll::Document
              skip_document_from_previous_error = 1
            end

            Jekyll.logger.warn("Page HTML Warning:", err.to_s)
          end
        else
          puts 'Valid!'
        end

        @doc.output
      end
    end
  end
end
