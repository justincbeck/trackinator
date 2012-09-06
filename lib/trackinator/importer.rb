require 'net/http'
require 'CSV'

require 'gdata'

require 'trackinator'

module Trackinator
  class Importer

    attr_accessor :dry_run

    def initialize you_track, google
      @you_track = you_track
      @google = google
    end

    def import file_name
      ticket_data = @google.get_tickets file_name

      issues = []
      issues.concat validate_headings(ticket_data[0])
      issues.concat validate_tickets(ticket_data)

      if issues.length == 0 && !@dry_run
        puts "importing..."

        ticket_data.each do |entry|
          issue_id = @you_track.is_issue_exists? entry
          false unless !issue_id.nil? ? @you_track.update_ticket(issue_id, entry) : @you_track.create_ticket(entry)
        end
      end

      issues
    end

    private

    def validate_headings headings
      []
    end

    def validate_tickets tickets
      puts "validating..."
      issues = []

      if tickets.length == 0
        return issues
      end

      project = tickets[0]['project']

      issues.concat(@you_track.project_exists?(project))

      tickets.each do |ticket|
        issues.concat(@you_track.you_track_fields_defined?(project, ticket.keys.collect! { |key| key.downcase }))

        issues.concat(validate_fields(ticket))
        issues.concat(validate_formats(ticket))
      end

      issues.uniq
    end

    def validate_fields ticket
      issues = []

      REQUIRED.each do |req_field|
        unless ticket.keys.include?(req_field) || ticket["type"].downcase.eql?("story")
          issues << "Validation Error: Ticket with ID: #{ticket["id"]} is missing required field '#{req_field}'"
        end
      end

      issues
    end

    def validate_formats ticket
      issues = []

      ticket.keys.each do |key|
        unless validate_format(key, ticket[key])
          issues << "Validation Error: Ticket with ID: #{ticket["id"]} has field '#{key}' with invalid format"
        end
      end

      issues
    end

    def validate_format key, value
      if Trackinator.const_defined?("#{key.upcase}") && Trackinator.const_get("#{key.upcase}").match(value.downcase).nil?
        false
      else
        true
      end
    end
  end
end