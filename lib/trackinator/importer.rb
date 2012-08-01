require 'net/http'
require 'CSV'

require 'gdata'

require 'trackinator/google'
require 'trackinator/you_track'

module Trackinator
  class Importer
    @you_track

    def initialize opts
      @you_track = YouTrack.new opts
      @google = Google.new opts
    end

    def import file_name
      ticket_data = @google.get_tickets file_name

      ticket_data.each do |entry|
        issue_id = @you_track.is_issue_exists? entry
        false unless !issue_id.nil? ? @you_track.update_ticket(issue_id, entry) : @you_track.create_ticket(entry)
      end
    end
  end
end