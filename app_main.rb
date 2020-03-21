# frozen_string_literal: true

require 'sinatra'
require 'line/bot'
require './search'

get '/' do
  'Hello world'
end

def client
  @client ||= Line::Bot::Client.new do |config|
    config.channel_id     = ENV['CHANNEL_ID']
    config.channel_secret = ENV['CHANNEL_SECRET']
    config.channel_token  = ENV['CHANNEL_TOKEN']
  end
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        @search_word = event.message['text']

        search_lyric

        if @error.nil?
          columns = []
          @songs.each do |song|
            column = {
              'title' => song['title'],
              'text' => song['lyric'],
              'actions' => {
                'type' => 'message',
                'label' => 'この曲ですか？',
                'text' => 'お役に立ててよかったです！'
              }
            }
            columns.push(column)
          end
          template = {
            'type' => 'carousel',
            'columns' => columns
          }
          message = {
            'type' => 'template',
            'altText' => '検索結果が表示できません',
            'template' => template
          }
        else
          message = {
            'type' => 'text',
            'text' => @error
          }
        end
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open('content')
        tf.write(response.body)
      end
    end
  end

  # Don't forget to return a successful response
  'OK'
end
