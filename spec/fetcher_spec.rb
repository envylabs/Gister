require 'gister/fetcher'
require 'helper'

describe Gister::Fetcher do
  subject { described_class.new }
  let(:key) {
    "https://gist.github.com/1111.json?file=app.js"
  }

  describe "set" do
    it "should store the object based on it's key" do
      subject.set(key, "hello")
      subject.get(key).should ==  "hello"
    end

    it "should bust the cache if the ENV changes" do
      subject.set key, "hello"
      ENV["CACHE_BUSTER"] = "1"
      subject.get(key).should == nil
      subject.set key, "hello"
      subject.get(key).should == "hello"
    end
  end

  describe "fetch" do
    use_vcr_cassette "gister", record: :new_episodes

    context "when the gist is already in the cache" do
      let(:cached_response) {
        "jQuery({})"
      }

      before do
        subject.set(key, cached_response)
      end

      it "should return the response from the cache" do
        subject.fetch(key).should == cached_response
      end
    end

    context "when the gist is not already in the cache" do

      context "and there is a successful response from gist" do
        let(:key) {
          "https://gist.github.com/1996296.json?file=challenge-1-2.js"
        }

        it "should return the response gist" do
          subject.fetch(key).should include("Anatomy of Backbone 1-2")
        end

        it "should store the response from gist into the cache" do
          subject.fetch(key)
          subject.get(key).should_not be_nil
        end
      end

      context "and gist responds with a 404" do
        let(:key) {
          "https://gist.github.com/199629612981921.json?file=challenge-1-2.js"
        }

        it "should raise a GistNotFound error" do
          expect { subject.fetch(key) }.to raise_error(described_class::GistNotFound)
        end
      end

      context "and gist responds with a 500" do
        let(:key) {
          "https://gist.github.com/client_error122.json?file=challenge-1-2.js"
        }

        it "should raise a ClientError error" do
          expect { subject.fetch(key) }.to raise_error(described_class::ClientError)
        end
      end

    end
  end


end
