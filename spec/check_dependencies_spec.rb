require File.join(File.dirname(__FILE__), "helpers")
require "sensu/extensions/check-dependencies"

describe "Sensu::Extension::CheckDependencies" do
  include Helpers

  before do
    @extension = Sensu::Extension::CheckDependencies.new
    @extension.logger = Sensu::Logger.get
    @extension.settings = {}
  end

  it "can provide the extension API" do
    expect(@extension).to respond_to(:name, :description, :definition, :safe_run, :has_key?, :[])
  end

  it "can determine if an event exists for a check dependency" do
    async_wrapper do
      event = event_template
      @extension.safe_run(event) do |output, status|
        expect(status).to eq(1)
        event[:check][:dependencies] = "invalid"
        @extension.safe_run(event) do |output, status|
          expect(status).to eq(1)
          event[:check][:dependencies] = ["foo"]
          @extension.safe_run(event) do |output, status|
            expect(status).to eq(1)
            stub_request(:get, "127.0.0.1:4567/events/i-424242/foo").
              to_return(:status => 200)
            @extension.safe_run(event) do |output, status|
              expect(status).to eq(0)
              async_done
            end
          end
        end
      end
    end
  end

  it "can determine if an event exists for a check dependency client/check pair" do
    async_wrapper do
      event = event_template
      event[:check][:dependencies] = ["foo"]
      @extension.safe_run(event) do |output, status|
        expect(status).to eq(1)
        event[:check][:dependencies] = ["foo", "bar/qux"]
        @extension.safe_run(event) do |output, status|
          expect(status).to eq(1)
          stub_request(:get, "127.0.0.1:4567/events/i-424242/qux").
            to_return(:status => 200)
          @extension.safe_run(event) do |output, status|
            expect(status).to eq(1)
            stub_request(:get, "127.0.0.1:4567/events/bar/qux").
              to_return(:status => 200)
            @extension.safe_run(event) do |output, status|
              expect(status).to eq(0)
              async_done
            end
          end
        end
      end
    end
  end
end
