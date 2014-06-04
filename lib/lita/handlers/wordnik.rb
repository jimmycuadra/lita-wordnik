require "lita"

module Lita
  module Handlers
    class Wordnik < Handler
      NO_RESULTS = "Wordnik doesn't have any results for that."

      def self.default_config(config)
        config.api_key = nil
      end

      route(/define\s+(.+)/i, :define, command: true, help: {
        "define WORD" => "Get the definition for WORD."
      })
      route(/^syn(?:onyms)?\s+(.*)$/i, :synonyms, command: true, help: {
        "synonyms WORD" => "Get synonyms for WORD."
      })
      route(/^words\s*like\s+(.*)$/i, :synonyms, command: true, help: {
        "words like WORD" => "Get synonyms for WORD."
      })
      route(/^ant(?:onyms)?\s+(.*)$/i, :antonyms, command: true, help: {
        "antonyms WORD" => "Get antonyms for WORD."
      })
      route(/^words\s*unlike\s+(.*)$/i, :antonyms, command: true, help: {
        "words unlike WORD" => "Get antonyms for WORD."
      })
      
      def define(response)
        return unless validate(response)
        word = response.matches[0][0]
        definition = get_definition(word)
        response.reply(definition)
      end
      
      def synonyms(response)
        return unless validate(response)
        word = response.matches[0][0]
        synonyms = get_synonyms(word)
        response.reply(synonyms)
      end
      
      def antonyms(response)
        return unless validate(response)
        word = response.matches[0][0]
        antonyms = get_antonyms(word)
        response.reply(antonyms)
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
      
      def get_synonyms(word)
        word = encode_word(word)
        url = "http://api.wordnik.com/v4/word.json/#{word}/relatedWords"
        Lita.logger.debug("Making Wordnik API request to #{url}.")
        process_response http.get(
          url,
          api_key: Lita.config.handlers.wordnik.api_key,
          useCanonical: true,
          relationshipTypes: "synonym",
          limitPerRelationshipType: 5
        )
      end
      
      def get_antonyms(word)
        word = encode_word(word)
        url = "http://api.wordnik.com/v4/word.json/#{word}/relatedWords"
        Lita.logger.debug("Making Wordnik API request to #{url}.")
        process_response http.get(
          url,
          api_key: Lita.config.handlers.wordnik.api_key,
          useCanonical: true,
          relationshipTypes: "antonym",
          limitPerRelationshipType: 5
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
          NO_RESULTS
        when 200
          data = MultiJson.load(response.body).first

          if data
            case data["relationshipType"]
            when "synonym"
              "(synonyms): #{data["words"].join(', ')}"
            when "antonym"
              "(antonyms): #{data["words"].join(', ')}"
            else
              "#{data["word"]} (#{data["partOfSpeech"]}): #{data["text"]}"
            end
          else
            NO_RESULTS
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
