require 'net/http'
require 'CSV'

require 'gdata'

module Trackinator
  class Importer
    @youtrack_cookie
    @youtrack_connection

    @google_headers
    @stack

    @col_count

    @youtrack_host
    @youtrack_port
    @youtrack_path_prefix

    def initialize opts
      @stack = []
      @google_connection = Net::HTTP
      @google_client = GData::Client::Spreadsheets.new

      google_login = opts[:google_username]
      youtrack_login = opts[:youtrack_username]

      @youtrack_host = opts[:youtrack_host]
      @youtrack_port = opts[:youtrack_port]
      @youtrack_path_prefix = opts[:youtrack_path_prefix]

      google_password = params[:google_password]
      youtrack_password = params[:youtrack_password]

      login_youtrack youtrack_login, youtrack_password

      @google_client.clientlogin(google_login, google_password)
    end

    def import file_name
      spreadsheet_feed = @google_client.get("http://spreadsheets.google.com/feeds/worksheets/#{get_spreadsheet_key(file_name)}/private/full").to_xml
      spreadsheet_list_data = @google_client.get(spreadsheet_feed.elements[1, 'entry'].elements[1, 'content'].attributes['src']).to_xml

      spreadsheet_list_data.elements.each('entry') do |entry|
        ticket_data = get_ticket_data entry
        issue_id = is_issue_exists? ticket_data
        false unless !issue_id.nil? ? update_ticket(issue_id, ticket_data) : create_ticket(ticket_data)
      end
    end

    private

    # Google API methods

    def get_spreadsheet_key file_name
      doc_feed = @google_client.get("http://spreadsheets.google.com/feeds/spreadsheets/private/full").to_xml

      doc_feed.elements.each ('entry') do |entry|
        if entry.elements['title'].text.eql? file_name
          return entry.elements[1].text[/spreadsheets\/(.*)/, 1]
        end
      end
    end

    def get_ticket_data entry
      data = {}

      REXML::XPath.match(entry, 'gsx:*').each do |col|
        data[col.name] = URI.escape(col.text) unless col.text.nil?
      end

      data
    end

    # YouTrack API methods

    def login_youtrack user_name, password
      @youtrack_connection = Net::HTTP.new @youtrack_host, @youtrack_port
      response = @youtrack_connection.post "#{@youtrack_path_prefix}rest/user/login", "login=#{user_name}&password=#{password}"
      @youtrack_cookie = response.response['Set-Cookie'].split('; ')[0]
    end

    def create_ticket data
      issue_id, create_response = create_youtrack_ticket data
      success = create_response.eql? "Created"

      success ? (success = update_ticket(issue_id, data)) : (return success)
      success ? update_dependencies([issue_id, data['id']]) : success
    end

    def update_ticket issue_id, data
      success = set_platform(issue_id, data['platform'])
      success ? (success = set_summary_and_description(issue_id, data['summary'], data['description'])) : (return success)
      success ? (success = set_type(issue_id, data['type'])) : (return success)
      success ? (success = set_import_identifier(issue_id, "#{data['project']}-#{data['id']}")) : (return success)
      success ? (success = set_design_reference(issue_id, "#{data['references']}")) : (return success) unless data['references'].nil?

      success
    end

    def update_dependencies issue
      issue_id = issue[0]
      issue_level = issue[1]

      if @stack.empty?
        @stack.push [issue_id, issue_level]
      else
        last_issue = @stack.last
        last_issue_id = last_issue[0]
        last_issue_level = last_issue[1]

        if issue_level.length <= last_issue_level.length
          @stack.pop
          update_dependencies issue
        else
          success = create_dependency last_issue_id, issue_id
          @stack.push issue

          success
        end
      end
    end

    # YouTrack API calls

    def is_issue_exists? data
      find_response_xml = REXML::Document.new(@youtrack_connection.get("#{@youtrack_path_prefix}rest/issue/byproject/#{data['project']}?filter=Import+Identifier:+#{data['project']}-#{data['id']}", { 'Cookie' => @youtrack_cookie, 'Content-Type' => 'text/plain; charset=utf-8' }).body)
      find_response_xml.elements['issues'].length > 0 ? find_response_xml.elements['issues/issue'].attributes['id'] : nil
    end

    def create_youtrack_ticket data
      response = @youtrack_connection.put("#{@youtrack_path_prefix}rest/issue?project=#{data['project']}&summary=#{data['summary']}&description=#{data['description']}&priority=#{data['priority']}", nil, { 'Cookie' => @youtrack_cookie, 'Content-Type' => 'text/plain; charset=utf-8' })
      return response.header["Location"].split("/").last, response.header.msg
    end

    def create_dependency parent_id, child_id
      response = @youtrack_connection.post("#{@youtrack_path_prefix}rest/issue/#{parent_id}/execute?command=parent+for+#{child_id}&disableNotifications=true", nil, { 'Cookie' => @youtrack_cookie })
      response.header.msg.eql? "OK"
    end

    def set_summary_and_description issue_id, summary, description
      return true if summary.nil?

      response = @youtrack_connection.post("#{@youtrack_path_prefix}rest/issue/#{issue_id}/?summary=#{summary}&description=#{description}&disableNotifications=true", nil, { 'Cookie' => @youtrack_cookie })
      response.header.msg.eql? "OK"
    end

    def set_platform issue_id, platform
      return true if platform.nil?

      response = @youtrack_connection.post("#{@youtrack_path_prefix}rest/issue/#{issue_id}/execute?command=Platform+#{platform}&disableNotifications=true", nil, { 'Cookie' => @youtrack_cookie })
      response.header.msg.eql? "OK"
    end

    def set_type issue_id, type
      return true if type.nil?

      response = @youtrack_connection.post("#{@youtrack_path_prefix}rest/issue/#{issue_id}/execute?command=Type+#{type}&disableNotifications=true", nil, { 'Cookie' => @youtrack_cookie })
      response.header.msg.eql? "OK"
    end

    def set_import_identifier issue_id, import_id
      return true if import_id.nil?

      response = @youtrack_connection.post("#{@youtrack_path_prefix}rest/issue/#{issue_id}/execute?command=Import+Identifier+#{import_id}&disableNotifications=true", nil, { 'Cookie' => @youtrack_cookie })
      response.header.msg.eql? "OK"
    end

    def set_design_reference issue_id, reference
      return true if reference.nil?

      response = @youtrack_connection.post("#{@youtrack_path_prefix}rest/issue/#{issue_id}/execute?command=Design+Reference+#{reference}&disableNotifications=true", nil, { 'Cookie' => @youtrack_cookie })
      response.header.msg.eql? "OK"
    end
  end
end