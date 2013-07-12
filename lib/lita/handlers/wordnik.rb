require "lita"

module Lita
  module Handlers
    class Wordnik < Handler
      def self.default_config(config)
        config.api_key = nil
      end

      route(/define\s+(.+)/i, :define, command: true, help: {
        "define WORD" => "Get the definition for WORD."
      })
    end
  end
end
