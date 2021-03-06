require 'spec_helper'
require 'puppet/file_serving/mount/scripts'

describe Puppet::FileServing::Mount::Scripts do
  before do
    @mount = Puppet::FileServing::Mount::Scripts.new("scripts")

    @environment = double('environment', :module => nil)
    @request = double('request', :environment => @environment)
  end

  describe "when finding files" do
    it "should fail if no module is specified" do
      expect { @mount.find("", @request) }.to raise_error(/No module specified/)
    end

    it "should use the provided environment to find the module" do
      expect(@environment).to receive(:module)

      @mount.find("foo", @request)
    end

    it "should treat the first field of the relative path as the module name" do
      expect(@environment).to receive(:module).with("foo")
      @mount.find("foo/bar/baz", @request)
    end

    it "should return nil if the specified module does not exist" do
      expect(@environment).to receive(:module).with("foo")
      @mount.find("foo/bar/baz", @request)
    end

    it "should return the file path from the module" do
      mod = double('module')
      expect(mod).to receive(:script).with("bar/baz").and_return("eh")
      expect(@environment).to receive(:module).with("foo").and_return(mod)
      expect(@mount.find("foo/bar/baz", @request)).to eq("eh")
    end
  end

  describe "when searching for files" do
    it "should fail if no module is specified" do
      expect { @mount.search("", @request) }.to raise_error(/No module specified/)
    end

    it "should use the node's environment to search the module" do
      expect(@environment).to receive(:module)

      @mount.search("foo", @request)
    end

    it "should treat the first field of the relative path as the module name" do
      expect(@environment).to receive(:module).with("foo")
      @mount.search("foo/bar/baz", @request)
    end

    it "should return nil if the specified module does not exist" do
      expect(@environment).to receive(:module).with("foo").and_return(nil)
      @mount.search("foo/bar/baz", @request)
    end

    it "should return the script path as an array from the module" do
      mod = double('module')
      expect(mod).to receive(:script).with("bar/baz").and_return("eh")
      expect(@environment).to receive(:module).with("foo").and_return(mod)
      expect(@mount.search("foo/bar/baz", @request)).to eq(["eh"])
    end
  end
end
