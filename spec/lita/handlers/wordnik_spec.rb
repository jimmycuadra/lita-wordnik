require "spec_helper"

describe Lita::Handlers::Wordnik, lita_handler: true do
  it { routes_command("define computer").to(:define) }

  it "sets the API key to nil by default" do
    expect(Lita.config.handlers.wordnik.api_key).to be_nil
  end

  describe "#define" do
    it "replies that the API key is required" do
      send_command("define computer")
      expect(replies.last).to include("API key required")
    end

    context "when the API key is set" do
      let(:body) do
        <<-BODY.chomp
[
  {
    "word": "computer",
    "text": "A device that computes, especially a programmable electronic \
machine that performs high-speed mathematical or logical operations or that \
assembles, stores, correlates, or otherwise processes information.",
    "partOfSpeech": "noun"
  }
]
BODY
      end
      let(:response) { double("Faraday::Response", status: 200, body: body) }

      before do
        Lita.config.handlers.wordnik.api_key = "abc123"
        allow_any_instance_of(
          Faraday::Connection
        ).to receive(:get).and_return(response)
      end

      it "replies with the definition" do
        send_command("define computer")
        expect(replies.last).to include("computer (noun): A device that")
      end

      it "URL encodes words" do
        word = "a phrase with a % sign in it"
        expect(URI).to receive(:encode).with(word)
        send_command("define #{word}")
      end

      it "replies that Wordnik didn't understand the word on 400 status" do
        allow(response).to receive(:status).and_return(400)
        send_command("define computer")
        expect(replies.last).to include("didn't understand")
      end

      it "replies that Wordnik has no definitions on 404 status" do
        allow(response).to receive(:status).and_return(404)
        send_command("define computer")
        expect(replies.last).to include("doesn't have any definitions")
      end

      it "logs an error and replies that the request completely failed" do
        allow(response).to receive(:status).and_return(500)
        send_command("define computer")
        expect(replies.last).to include("request failed")
      end
    end
  end
end
