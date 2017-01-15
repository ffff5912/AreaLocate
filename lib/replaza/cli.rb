require 'replaza'
require 'thor'
require 'nokogiri'
require 'mechanize'

module Replaza
    SOURCEURL = 'http://www.iphiroba.jp/'

    class CLI < Thor
        desc "bundle exec exe/replaza find {ip address} {ua}", ''
        def find(ip, ua = 'Mac Safari')
            agent = RegionAgent.new(ua)
            form = RequestForm.new({'action' => 'ip.php'}, {'name' => 'ip'})
            html = agent.post(SOURCEURL, ip, form).content.toutf8
            content = Parser::parse(html).each do |content|
                puts content.join(': ')
            end
        end
    end

    class RegionAgent
        def initialize(ua)
            @agent = Mechanize.new()
            @agent.user_agent = ua
        end

        def post(url, ip, request_form)
            form = @agent.get(url).form_with(request_form.action)
            form.field_with(request_form.field).value = ip
            @agent.submit(form, form.buttons.first)
        end
    end

    class Parser
        def self.parse(html)
            document = Nokogiri::HTML(html, nil, 'utf-8')
            document.search('table[@class="result"] > tr').map do |node|
                [node.css('th').inner_text, node.css('td').inner_text]
            end
        end
    end

    class RequestForm
        attr_reader :action, :field
        def initialize(action, field)
            @action = action
            @field = field 
        end
    end
end
