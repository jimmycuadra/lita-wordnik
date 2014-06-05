require "spec_helper"

describe Lita::Handlers::Wordnik, lita_handler: true do
  let(:response) { double("Faraday::Response", status: 200, body: body) }

  it { routes_command("define computer").to(:define) }
  it { routes_command("synonyms cold").to(:synonyms) }
  it { routes_command("syn cold").to(:synonyms) }
  it { routes_command("words like cold").to(:synonyms) }
  it { routes_command("antonyms cold").to(:antonyms) }
  it { routes_command("ant cold").to(:antonyms) }
  it { routes_command("words unlike cold").to(:antonyms) }

  it "sets the API key to nil by default" do
    expect(Lita.config.handlers.wordnik.api_key).to be_nil
  end

  context "with Faraday stubbing" do
    before do
      allow_any_instance_of( Faraday::Connection).to receive(:get).and_return(response)
    end

    describe "#define" do
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

      it "replies that the API key is required" do
        send_command("define computer")
        expect(replies.last).to include("API key required")
      end

      context "when the API key is set" do
        before { Lita.config.handlers.wordnik.api_key = "abc123" }

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
          expect(replies.last).to include("doesn't have any results")
        end

        it "logs an error and replies that the request completely failed" do
          allow(response).to receive(:status).and_return(500)
          send_command("define computer")
          expect(replies.last).to include("request failed")
        end

        context "when the response has no definitions" do
          let(:body) { "[]" }

          it "replies that Wordnik has no definitions" do
            send_command("define whiskey stone")
            expect(replies.last).to include("doesn't have any results")
          end
        end
      end
    end

    describe "#synonyms" do
      let(:body) do
        <<-BODY.chomp
[
  {
    "words": [
      "stoical",
      "frigid",
      "unconcerned",
      "bleak",
      "indifferent"
    ],
    "relationshipType": "synonym"
  }
]
BODY
      end

      before { Lita.config.handlers.wordnik.api_key = "abc123" }

      it "replies with synonyms" do
        send_command("synonyms cold")
        expect(replies.last).to include("(synonyms): stoical, frigid, unconcerned, bleak, indifferent")
      end
    end

    describe "#antonyms" do
      let(:body) do
    <<-BODY.chomp
[
  {
    "words": [
      "hot"
    ],
    "relationshipType": "antonym"
  }
]
BODY
      end

      before { Lita.config.handlers.wordnik.api_key = "abc123" }

      it "replies with antonyms" do
        send_command("antonyms cold")
        expect(replies.last).to include("(antonyms): hot")
      end
    end
  end
end
