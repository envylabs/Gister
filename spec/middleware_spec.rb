require 'gister/middleware'
require_relative 'helper'
require 'rack'

describe Gister::Middleware do
  let(:app) { load_app }
  let(:response) { request(app, path) } 

  subject { response }

  describe "when responding to a request with a gist path" do
    let(:path) {
      "/gist/1111.json?file=app.js&callback=jQueryCallback&_=12012981921"
    }

    context 'and getting content from the fetcher works' do
      let(:response_body) {
        "{hello:'world'}"
      }

      before do
        app.stub(:fetch_by_path).and_return(response_body)
      end

      it "should use the url as the key to fetcher with the callback or timestamp" do
        app.should_receive(:fetch_by_path).with("https://gist.github.com/1111.json?file=app.js").and_return(response_body)

        subject
      end

      it "should wrap the response from fetcher in the callback param" do
        subject[2].should == ["jQueryCallback(#{response_body})"]
      end

      it "should return a 200" do
        subject[0].should == 200
      end

      it "should have a content type of application/javascript" do
        subject[1]['Content-Type'].should == "application/javascript"
      end
    end

    context 'and getting content from the fetcher raises a ClientError' do
      before do
        app.stub(:fetch_by_path).and_raise(Gister::Fetcher::ClientError)
      end

      it "should return a 404" do
        subject[0].should == 404
      end

      it "should have an empty body" do
        subject[2].should == [""]
      end
    end
  end

  describe "when responding to a request without a gist path" do
    let(:path) { "/hello" }

    it "should pass through to the inner app" do
      subject[2].should == 'Success'
    end

  end

  def load_app
    described_class.new inner_app, fetcher
  end

  def inner_app
    lambda { |env| [200, {'Content-Type' => 'text/plain'}, 'Success'] }
  end

  def request(app, path, options = {})
    app.call Rack::MockRequest.env_for(path, options)
  end

  def fetcher
    Gister::Fetcher.new
  end
end
