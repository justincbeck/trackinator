require 'erb'
include ERB::Util

module Trackinator
  class YouTrack
    def initialize opts
      @stack = []

      @host = opts[:host]
      @port = opts[:port]
      @path_prefix = opts[:path_prefix]
    end

    def is_logged_in?
      !@cookie.nil?
    end

    def login username, password
      @connection = Net::HTTP.new @host, @port
      response = @connection.post "#{@path_prefix}rest/user/login", "login=#{username}&password=#{password}"
      if response.header.msg.eql? "OK"
        @cookie = response.response['Set-Cookie'].split('; ')[0]
      end
    end

    def create_ticket data
      issue_id, create_response = create_youtrack_ticket data
      success = create_response.eql? "Created"

      success ? (success = update_ticket(issue_id, data)) : (return success)
      success ? update_dependencies([issue_id, data['id']]) : success
    end

    def update_ticket issue_id, data
      success = set_subsystem(issue_id, data['subsystem'])
      success ? (success = set_summary_and_description(issue_id, data['summary'], data['description'], data['outcome'])) : (return success)
      success ? (success = set_type(issue_id, data['type'])) : (return success)
      success ? (success = set_import_identifier(issue_id, "#{data['project']}-#{data['id']}")) : (return success)
      success ? (success = set_design_reference(issue_id, "#{data['designreference']}")) : (return success) unless data['designreference'].nil?

      success
    end

    def project_exists?(project)
      issues = []

      response = @connection.get("#{@path_prefix}rest/admin/project/#{project}", { 'Cookie' => @cookie, 'Content-Type' => 'text/plain; charset=utf-8' })
      if response.header.msg.eql?("Not Found")
        issues << "Project Error: Project doesn't exist!"
      end

      issues
    end

    # Here's a potential approach for validating that YouTrack fields are present
    #
    # get YouTrack fields from server
    # augment YouTrack fields where necessary (import identifier?)
    # copy YouTrack fields and normalize copy (remove spaces, downcase)
    # create map of YouTrack fields to nYouTrack fields
    # get Google fields from doc
    # normalize Google fields (remove spaces, downcase)
    # subtract nGoogle from nYouTrack (leaving only missing YouTrack fields)
    # subtract nYouTrack from nGoogle (leaving only missing Google fields)
    # warn on missing nGoogle
    # fail validation on nYouTrack using map to get actual field names for display
    # ...
    # or, just hard code the fucking thing and be done with it

    def required_you_track_fields_defined?(project)
      you_track_fields = []
      issues = []

      response = @connection.get("#{@path_prefix}rest/admin/project/#{project}/customfield", { 'Cookie' => @cookie, 'Content-Type' => 'text/plain; charset=utf-8' })
      response_xml = REXML::Document.new(response.body)

      response_xml.elements.each('projectCustomFieldRefs/projectCustomField') do |element|
        you_track_fields << element.attributes["name"]
      end

      YOU_TRACK_REQUIRED.each do |required_field|
        unless you_track_fields.include?(required_field)
          issues << "Validation Error: Required field '#{required_field}' not found in YouTrack project"
        end
      end

      issues
    end

    def is_issue_exists? data
      find_response_xml = REXML::Document.new(@connection.get("#{@path_prefix}rest/issue/byproject/#{data['project']}?filter=Import+Identifier:+#{data['project']}-#{data['id']}+Subsystem:+#{data['subsystem']}", { 'Cookie' => @cookie, 'Content-Type' => 'text/plain; charset=utf-8' }).body)
      find_response_xml.elements['issues'].length > 0 ? find_response_xml.elements['issues/issue'].attributes['id'] : nil
    end

    private

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

    def create_youtrack_ticket data
      response = @connection.put("#{@path_prefix}rest/issue?project=#{data['project']}&summary=#{url_encode(data['summary'])}&description=#{url_encode(construct_description(data['description'], data['outcome']))}&priority=#{data['priority']}", nil, { 'Cookie' => @cookie, 'Content-Type' => 'text/plain; charset=utf-8' })
      return response.header["Location"].split("/").last, response.header.msg
    end

    def create_dependency parent_id, child_id
      response = @connection.post("#{@path_prefix}rest/issue/#{parent_id}/execute?command=parent+for+#{child_id}&disableNotifications=true", nil, { 'Cookie' => @cookie })
      response.header.msg.eql? "OK"
    end

    def set_summary_and_description issue_id, summary, description, outcome
      response = @connection.post("#{@path_prefix}rest/issue/#{issue_id}/?summary=#{url_encode(summary)}&description=#{url_encode(construct_description(description, outcome))}&disableNotifications=true", nil, { 'Cookie' => @cookie })
      response.header.msg.eql? "OK"
    end

    def set_subsystem issue_id, subsystem
      return true if subsystem.nil?

      response = @connection.post("#{@path_prefix}rest/issue/#{issue_id}/execute?command=Subsystem+#{URI.escape(subsystem)}&disableNotifications=true", nil, { 'Cookie' => @cookie })
      response.header.msg.eql? "OK"
    end

    def set_type issue_id, type
      return true if type.nil?

      response = @connection.post("#{@path_prefix}rest/issue/#{issue_id}/execute?command=Type+#{URI.escape(type)}&disableNotifications=true", nil, { 'Cookie' => @cookie })
      response.header.msg.eql? "OK"
    end

    def set_import_identifier issue_id, import_id
      return true if import_id.nil?

      response = @connection.post("#{@path_prefix}rest/issue/#{issue_id}/execute?command=Import+Identifier+#{URI.escape(import_id)}&disableNotifications=true", nil, { 'Cookie' => @cookie })
      response.header.msg.eql? "OK"
    end

    def set_design_reference issue_id, reference
      return true if reference.nil?

      response = @connection.post("#{@path_prefix}rest/issue/#{issue_id}/execute?command=Design+Reference+#{URI.escape(reference)}&disableNotifications=true", nil, { 'Cookie' => @cookie })
      response.header.msg.eql? "OK"
    end

    def construct_description description, outcome
      return if description.nil?

      template = ERB.new <<-EOF
<% unless outcome.nil? %>'''Steps'''<% end %>
<% if !description.nil? && description.split(';').length > 1 %><% description.split(';').each do |step| %>
*<%= step.strip %><% end %>
<% else %>
<%= description %>
<% end %>
<% unless outcome.nil? %>'''Outcome'''
<% end %>
<%= outcome %>
      EOF

      template.result(binding)
    end
  end
end