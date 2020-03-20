# frozen_string_literal: false

require 'selenium-webdriver'

def search_lyric(search_word)
  options = Selenium::WebDriver::Chrome::Options.new
  options.binary = ENV.fetch('GOOGLE_CHROME_SHIM')
  options.add_argument('headless')
  options.add_argument('disable-gpu')

  driver = Selenium::WebDriver.for :chrome
  driver.navigate.to 'https://www.uta-net.com/user/index_search/search1.html'
  wait = Selenium::WebDriver::Wait.new(timeout: 30)
  wait.until { driver.find_element(:tag_name, 'input').displayed? }
  begin
    search_box = driver.find_element(:tag_name, 'input')
  rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
  end
  search_word = search_word.split
  search_box.send_keys(search_word)
  search_box.submit

  wait.until { driver.find_element(:id, 'search_list').displayed? }
  result = driver.find_element(:id, 'search_list')
  song_info = result.find_elements(:tag_name, 'a')
  song_name = song_info[0]
  song_name = song_name.text.to_i
  artist_name = song_info[1]
  artist_name = artist_name.text.to_i
  @message = 'その曲は' << song_name << ' - ' << artist_name << 'ではないですか？'
  # puts @message
  driver.close
  driver.quit
end

search_lyric