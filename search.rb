# frozen_string_literal: false

require 'selenium-webdriver'

def search_lyric
  driver = Selenium::WebDriver.for :chrome
  driver.navigate.to 'https://www.uta-net.com/user/index_search/search1.html'
  wait = Selenium::WebDriver::Wait.new(timeout: 30)

  begin
    wait.until { driver.find_element(:tag_name, 'input').displayed? }
    search_box = driver.find_element(:tag_name, 'input')
  rescue Selenium::WebDriver::Error::NoSuchElementError
    @error = 'すみません、エラーが発生しました'
  end

  keyword = @search_word.split
  keyword.each do |word|
    search_box.send_keys(word)
  end
  search_box.submit

  begin
    wait.until { driver.find_element(:id, 'search_list').displayed? }
    result = driver.find_element(:id, 'search_list')
    dts = result.find_elements(:tag_name, 'dt')
    dds = result.find_elements(:tag_name, 'dd')
    @songs = []
    dts.zip(dds).each do |title, lyric|
      song = {}
      song_info = title.find_elements(:tag_name, 'a')
      song_name = song_info[0]
      song_name = song_name.text
      artist_name = song_info[1]
      artist_name = artist_name.text
      song_title = song_name << ' - ' << artist_name
      song['title'] = song_title
      song_lyric = lyric.find_element(:tag_name, 'p')
      song_lyric = song_lyric.text
      song['lyric'] = song_lyric
      @songs.push(song) if @songs.length < 10
    end
  rescue Selenium::WebDriver::Error::NoSuchElementError
    @error = 'すみません、エラーが発生しました'
  end
  driver.close
  driver.quit
end
