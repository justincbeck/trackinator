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
        @you_track = mock(YouTrack)
        @you_track.stub!(:project_exists?).and_return([])
        @you_track.stub!(:you_track_fields_defined?).and_return([])

        @google = mock(Google)

        @importer = Importer.new @you_track, @google
      end

      it "#validate_tickets should return no issues and validate" do
        @importer.stub!(:validate_fields).and_return([])
        @importer.stub!(:validate_formats).and_return([])

        issues = @importer.send(:validate_tickets, [{}])
        issues.should == []
      end

      it "#validate_tickets should return no issues and not validate" do
        @importer.stub!(:validate_fields).and_return([])
        @importer.stub!(:validate_formats).and_return([])

        issues = @importer.send(:validate_tickets, [])
        issues.should == []
      end
    end

    context "validate_fields" do
      before(:each) do
        @you_track = mock(YouTrack)
        @google = mock(Google)

        @importer = Importer.new @you_track, @google
      end

      it "#validate_fields should return no issues and validate feature" do
        issues = @importer.send(:validate_fields, { "type" => "feature", "project" => "YTTP", "id" => "1.2", "summary" => "A summary", "description" => "A description", "outcome" => "An outcome" })
        issues.should == []
      end

      it "#validate_fields should return 1 issue: missing project" do
        issues = @importer.send(:validate_fields, { "type" => "feature", "id" => "1.2", "summary" => "A summary", "description" => "A description", "outcome" => "An outcome" })
        issues.size.should == 1
        issues[0].should == "Validation Error: Ticket with ID: 1.2 is missing required field 'project'"
      end

      it "#validate_fields should return 1 issue: missing id" do
        issues = @importer.send(:validate_fields, { "type" => "feature", "project" => "YTTP", "summary" => "A summary", "description" => "A description", "outcome" => "An outcome" })
        issues.size.should == 1
        issues[0].should == "Validation Error: Ticket with ID:  is missing required field 'id'"
      end

      it "#validate_fields should return 1 issue: missing summary" do
        issues = @importer.send(:validate_fields, { "type" => "feature", "project" => "YTTP", "id" => "1.2", "description" => "A description", "outcome" => "An outcome" })
        issues.size.should == 1
        issues[0].should == "Validation Error: Ticket with ID: 1.2 is missing required field 'summary'"
      end

      it "#validate_fields should return 1 issue: missing description" do
        issues = @importer.send(:validate_fields, { "type" => "feature", "project" => "YTTP", "id" => "1.2", "summary" => "A summary", "outcome" => "An outcome" })
        issues.size.should == 1
        issues[0].should == "Validation Error: Ticket with ID: 1.2 is missing required field 'description'"
      end

      it "#validate_fields should return 1 issue: missing outcome" do
        issues = @importer.send(:validate_fields, { "type" => "feature", "project" => "YTTP", "id" => "1.2", "summary" => "A summary", "description" => "A description" })
        issues.size.should == 1
        issues[0].should == "Validation Error: Ticket with ID: 1.2 is missing required field 'outcome'"
      end
    end

    context "validate_formats" do
      before(:each) do
        @you_track = mock(YouTrack)
        @google = mock(Google)

        @importer = Importer.new @you_track, @google
      end

      it "#validate_formats should return no issues and validate" do
        issues = @importer.send(:validate_formats, { "type" => "feature" })
        issues.should == []
      end

      it "#validate_formats should return no issues and validate" do
        issues = @importer.send(:validate_formats, { "type" => "foo" })
        issues.size.should == 1
        issues[0].should == "Validation Error: Ticket with ID:  has field 'type' with invalid format"
      end

      it "#validate_formats should return no issues and validate" do
        issues = @importer.send(:validate_formats, { "id" => "1.2" })
        issues.should == []
      end

      it "#validate_formats should return no issues and validate" do
        issues = @importer.send(:validate_formats, { "id" => "junk" })
        issues.size.should == 1
        issues[0].should == "Validation Error: Ticket with ID: junk has field 'id' with invalid format"
      end

      it "#validate_formats should return no issues and validate" do
        issues = @importer.send(:validate_formats, { "priority" => "normal" })
        issues.should == []
      end

      it "#validate_formats should return no issues and validate" do
        issues = @importer.send(:validate_formats, { "priority" => "junk" })
        issues.size.should == 1
        issues[0].should == "Validation Error: Ticket with ID:  has field 'priority' with invalid format"
      end
    end
  end
end
