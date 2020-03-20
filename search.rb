# frozen_string_literal: true

require 'selenium-webdriver'

def search_lyric(search_word)
  options = Selenium::WebDriver::Chrome::Options.new
  options.binary = ENV.fetch('GOOGLE_CHROME_SHIM')
  options.add_argument('headless')
  options.add_argument('disable-gpu')

  driver = Selenium::WebDriver.for :chrome, options: options
  driver.navigate.to 'https://www.uta-net.com/user/index_search/search1.html'
  wait = Selenium::WebDriver::Wait.new(timeout: 30)
  wait.until { driver.find_element(:tag_name, 'input').displayed? }
  begin
    search_box = driver.find_element(:tag_name, 'input')
  rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
  end
  search_box.send_keys(search_word)
  search_box.submit

  wait.until { driver.find_element(:id, 'search_list').displayed? }
  result = driver.find_element(:id, 'search_list')
  song_info = result.find_elements(:tag_name, 'a')
  song_name = song_info[0].text
  artist_name = song_info[1].text
  @message = 'その曲は' << song_name << ' - ' << artist_name << 'ではないですか？'
  driver.close
  driver.quit
end

# search_lyric
