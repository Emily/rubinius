require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../shared/cover_and_include', __FILE__)
require File.expand_path('../shared/cover', __FILE__)

describe "Range#===" do
  ruby_version_is ""..."1.9" do
    it_behaves_like :range_cover_and_include, :===
    it_behaves_like :range_cover, :===
  end

  ruby_version_is "1.9" do
    it "returns the result of calling #include? on self" do
      range = 0...10
      range.should_receive(:include?).with(2).and_return(:true)
      (range === 2).should == :true
    end
  end
end
