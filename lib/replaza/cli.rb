require 'replaza'
require 'thor'
require 'nokogiri'
require 'mechanize'

module Replaza
    SOURCEURL = 'http://www.iphiroba.jp/'
    KAKUNINKUN = 'http://kakunin.net/'

    class CLI < Thor
        desc "bundle exec exe/replaza find {ip address} {ua}", ''
        def find(ip, ua = 'Mac Safari')
            agent = RegionAgent.new(ua)
            form = RequestForm.new({'action' => 'ip.php'}, {'name' => 'ip'})
            html = agent.post(SOURCEURL, ip, form).content.toutf8
            Parser::parse(html, 'table[@class="result"] > tr')
                .map {|node| [node.css('th').inner_text, node.css('td').inner_text]}
                .each {|content| puts content.join(': ')}

            whois = Parser::parse(html, 'form[@name="ip_result"] > div[@class="result"] > pre')
            puts whois.inner_text
        end

        desc "bundle exec exe/replaza myip [ua]", ''
        def myip(ua = 'Mac Safari')
            agent = RegionAgent.new(ua)
            html = agent.get(KAKUNINKUN).content.toutf8
            Parser::parse(html, 'table > tr')
                .map {|node| puts node.css('td').inner_text.gsub(/[\n|\t| ]+/, ' ')}
        end
    end

    class RegionAgent
        def initialize(ua)
            @agent = Mechanize.new()
            @agent.user_agent = ua
        end

        def get(url)
            @agent.get(url)
        end

        def post(url, ip, request_form)
            form = @agent.get(url).form_with(request_form.action)
            form.field_with(request_form.field).value = ip
            @agent.submit(form, form.buttons.first)
        end
    end

    class Parser
        def self.parse(html, selector)
            document = Nokogiri::HTML(html, nil, 'utf-8')
            nodes = document.search(selector)
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
