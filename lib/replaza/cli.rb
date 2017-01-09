require 'replaza'
require 'thor'
require 'mechanize'

module Replaza
    SOURCEURL = 'http://www.iphiroba.jp/'

    class CLI < Thor
    end

    class RegionAgent
        def initialize(url, agent)
            @agent = Mechanize.new()
            @agent.user_agent = agent
            @url = url
        end

        def post(ip)
            agent.get(@url) do |page|
                response = page.form_with(:action => 'ip.php') do |form|
                    form.field_with(:name => 'ip').value(ip)
                end.submit
            end
        end
    end
end
