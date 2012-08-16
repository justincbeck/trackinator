require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

module Trackinator
  describe Importer do
    context "import" do
      before(:each) do
        @google = mock(Google)

        @you_track = mock(YouTrack)
        @you_track.stub!(:is_issue_exists?).and_return(nil)
        @you_track.stub!(:create_ticket).and_return(true)

        @importer = Importer.new @you_track, @google
        @importer.stub!(:validate_tickets).and_return([])
      end

      it "#import should return no issues and import" do
        @google.stub!(:get_tickets).and_return([{"type" => "story"}])
        $stdout.should_receive(:puts).with("importing...")

        issues = @importer.import "filename"
        issues.should == []
      end

      it "#import should return no issues and not import" do
        @google.stub!(:get_tickets).and_return([])
        $stdout.should_receive(:puts).with("importing...")

        issues = @importer.import "filename"
        issues.should == []
      end
    end

    context "validate_tickets" do
      before(:each) do
        @google = mock(Google)

        @you_track = mock(YouTrack)
        @you_track.stub!(:is_issue_exists?).and_return(nil)
        @you_track.stub!(:create_ticket).and_return(true)

        @importer = Importer.new @you_track, @google
        @importer.stub!(:validate_tickets).and_return([])
      end
    end
  end
end
