module Trackinator
  class Google
    def initialize client
      @client = client
    end

    def login opts
      begin
        @token = @client.clientlogin(opts[:google_username], opts[:google_password])
      rescue Exception => e
        @token = nil
      end
    end

    def is_logged_in?
      !@token.nil?
    end

    def get_tickets file_name
      puts "reading document..."

      spreadsheet_list_data = get_spreadsheet_list_data file_name
      tickets = []

      spreadsheet_list_data.elements.each('entry') do |entry|
        tickets << get_ticket_data(entry)
      end

      tickets
    end

    private

    def get_spreadsheet_list_data file_name
      spreadsheet_feed = @client.get("http://spreadsheets.google.com/feeds/worksheets/#{get_spreadsheet_key(file_name)}/private/full").to_xml
      spreadsheet_list_url = spreadsheet_feed.elements[1, 'entry'].elements[1, 'content'].attributes['src']
      @client.get(spreadsheet_list_url).to_xml
    end

    def get_spreadsheet_key file_name
      doc_feed = @client.get("http://spreadsheets.google.com/feeds/spreadsheets/private/full").to_xml

      doc_feed.elements.each('entry') do |entry|
        if entry.elements['title'].text.eql? file_name
          return entry.elements[1].text[/spreadsheets\/(.*)/, 1]
        end
      end
    end

    def get_ticket_data entry
      data = {}

      REXML::XPath.match(entry, 'gsx:*').each do |col|
        data[col.name] = col.text unless col.text.nil?
      end

      data
    end
  end
end
