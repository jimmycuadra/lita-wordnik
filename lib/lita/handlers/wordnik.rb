require "lita"

module Lita
  module Handlers
    class Wordnik < Handler
      NO_DEFINITIONS = "Wordnik doesn't have any definitions for that."

      def self.default_config(config)
        config.api_key = nil
      end

      route(/define\s+(.+)/i, :define, command: true, help: {
        "define WORD" => "Get the definition for WORD."
      })

      def define(response)
        return unless validate(response)
        word = response.matches[0][0]
        definition = get_definition(word)
        response.reply(definition)
      end

      private

      def get_definition(word)
        word = encode_word(word)
        url = "http://api.wordnik.com/v4/word.json/#{word}/definitions"
        Lita.logger.debug("Making Wordnik API request to #{url}.")
        process_response http.get(
          url,
          api_key: Lita.config.handlers.wordnik.api_key,
          limit: 1,
          includeRelated: false,
          useCanonical: true,
          includeTags: false
        )
      end

      def encode_word(word)
        begin
          URI.parse(word)
          return word
        rescue URI::InvalidURIError
          return URI.encode(word)
        end
      end

      def process_response(response)
        case response.status
        when 400
          "Wordnik didn't understand that word."
        when 404
          NO_DEFINITIONS
        when 200
          data = MultiJson.load(response.body).first

          if data
            "#{data["word"]} (#{data["partOfSpeech"]}): #{data["text"]}"
          else
            NO_DEFINITIONS
          end
        else
          Lita.logger.error("Wordnik request failed: #{response.inspect}")
          "Wordnik request failed. See the Lita logs."
        end
      end

      def validate(response)
        if Lita.config.handlers.wordnik.api_key.nil?
          response.reply "Wordnik API key required."
          return
        end

        true
      end

      Lita.register_handler(Wordnik)
    end
  end
end
