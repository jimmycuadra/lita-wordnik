require "spec_helper"

describe Lita::Handlers::Wordnik, lita_handler: true do
  it { routes_command("define computer").to(:define) }

  it "sets the API key to nil by default" do
    expect(Lita.config.handlers.wordnik.api_key).to be_nil
  end
end
