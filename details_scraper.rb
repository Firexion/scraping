require 'kimurai'
require_relative 'event'
require_relative 'player'

class DetailsScraper < Kimurai::Base
  @name = 'eng_job_scraper'
  @engine = :selenium_chrome

  def create_player(char_element)
    name = char_element.css('td')[0].text.gsub(/[[:space:]]/, '')
    faction = char_element.css('td')[3].nil? ? '' : char_element.css('td')[3].text.gsub(/[[:space:]]/, '')
    list = if !char_element.css('td')[2].nil? && !char_element.css('td')[2].css('a').nil? &&
      !char_element.css('td')[2].css('a').attribute('href').nil?
             "https://tabletop.to/#{char_element.css('td')[2].css('a').attribute('href').value.gsub(/[[:space:]]/, '')}"
           else
             ''
           end
    Player.new(name, faction, list)
  end

  def scrape_page
    players = []
    doc = browser.current_response
    player_table = doc.css('tbody')
    player_table.css('tr').each do |char_element|
      players << create_player(char_element)
    end
    players
  end

  def parse(*)
    scrape_page
  end

end
