require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

module Trackinator
  describe Google do
    context "login" do
      before(:each) do
        @client = mock(GData::Client::Spreadsheets)
        @google = Google.new(@client)
      end

      it "#login should assign a token" do
        @client.stub!(:clientlogin).and_return(true)
        @google.login({})
        @google.is_logged_in?.should == true
      end

      it "#login should not assign a token" do
        @client.stub!(:clientlogin).and_raise(Exception.new)
        @google.login({})
        @google.is_logged_in?.should == false
      end
    end

    context "get_tickets" do
      before(:each) do
        @client = mock(GData::Client::Spreadsheets)
        @google = Google.new(@client)
        @spreadsheet_list_data = mock(REXML::Document)
        @spreadsheet_list_data.stub!(:elements).and_return(@spreadsheet_list_data)
        @google.stub!(:get_spreadsheet_list_data).and_return(@spreadsheet_list_data)
        @google.stub!(:get_ticket_data).and_return( {"foo" => "bar"} )
      end

      it "#get_tickets should return an empty array" do
        @spreadsheet_list_data.stub!(:each).with("entry")
        tickets = @google.get_tickets("filename")
        tickets.length.should == 0
      end

      it "#get_tickets should return an array of 1" do
        @spreadsheet_list_data.stub!(:each).with("entry").and_yield(%{entry})
        tickets = @google.get_tickets("filename")
        tickets.length.should == 1
        tickets[0]["foo"].should == "bar"
      end
    end

    context "get_spreadsheet_list_data" do
      it "#get_spreadsheet_list_data should do something" do
        pending
      end
    end

    context "get_spreadsheet_key" do
      it "#get_spreadsheet_key should do something" do
        pending
      end
    end

    context "get_ticket_data" do
      it "#get_ticket_data should do something" do
        pending
      end
    end
  end
end
