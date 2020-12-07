require 'kimurai'
require_relative 'details_scraper'
require_relative 'event'

class EventScraper < Kimurai::Base
  @name = 'eng_job_scraper'
  @start_urls = ['https://tabletop.to/events/aos']
  @engine = :selenium_chrome

  def create_event(char_element)
    title = char_element.css('a')[0].attributes['href'].value.gsub(/[[:space:]]/, '')
    link = "https://tabletop.to/#{title}"
    date = char_element.css('span')[0].children[1].text.gsub(/[[:space:]]/, '')
    Event.new(title.upcase, link, date)
  end

  def scrape_page
    doc = browser.current_response
    returned_events = doc.css('tbody')
    returned_events.css('tr').each do |char_element|
      event = create_event char_element
      @events << event unless @events.include?(event)
    end
  end

  def click_next_page(temp)
    temp = 5 if temp > 4 && temp + 2 < @num
    temp += 7 - @num if temp + 3 > @num
    browser.find("/html/body/div[3]/section/div/div[2]/div/div[2]/div[3]/div[2]/div/ul/li[#{temp}]/a").click
    puts "🔹 🔹 🔹 CURRENT NUMBER OF EVENTS: #{@events.count}🔹 🔹 🔹"
    puts '🔺 🔺 🔺 🔺 🔺  CLICKED NEXT BUTTON 🔺 🔺 🔺 🔺 '
  end

  def write_data
    CSV.open('events.csv', 'w') do |csv|
      csv << @events
    end

    File.open('events.json', 'w') do |f|
      f.write(JSON.pretty_generate(@events))
    end
  end

  def find_num_pages
    pagination = browser.current_response.css('#events_paginate').css('.pagination')[0]
    @num = pagination.children[pagination.children.size - 1].text.to_i
  end

  def parse_players
    @events.each do |event|
      t = Thread.new { event.players = DetailsScraper.parse!(:parse, url: event.link) }
      t.join
    end
  end

  def parse(*)
    @events = []
    find_num_pages
    @num.times do |i|
      click_next_page(i + 1)
      scrape_page
    end

    parse_players
    write_data
  end
end

EventScraper.crawl!
