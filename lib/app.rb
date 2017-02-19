require 'mechanize'
require 'pp'
require 'discordrb'
require 'dotenv'
Dotenv.load('../.env')
require 'bitly'

Bitly.use_api_version_3
mechanize = Mechanize.new

bot = Discordrb::Commands::CommandBot.new token: ENV['DISCORD'], client_id: '250138918282985473', prefix: '!!'
Bitly.configure do |config|
  config.api_version = 3
  config.access_token = ENV['BITLY']
end

bot.command :player do |event|
  content = event.message.content.split(' ')
  player_name = content[1..-1].join('+')
  player_name_pm = content[1..-1].map(&:capitalize).join(' ')
  message = []

  begin
    # name from the message sent to the bot
    page = mechanize.get("https://secure.tibia.com/community/?subtopic=characters&name=#{player_name}")
    shorten = Bitly.client.shorten("https://secure.tibia.com/community/?subtopic=characters&name=#{player_name}")
    # Sends Shortened link to User as a Private Message because you can't send clickable links on Markdown
    event.user.pm("Full profile of **#{player_name_pm}**: #{shorten.short_url}")

    # Yes, these are all pushes to an array so I don't gate rate limited on discord and this way I can
    # Format the message nicely :-)
    # These are all xPaths from the Tibia website.
    message.push("Name: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[2]/td[2]').text}")
    message.push("Sex: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[3]/td[2]').text}")
    message.push("Vocation: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[4]/td[2]').text}")
    message.push("Level: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[5]/td[2]').text}")
    message.push("World: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[7]/td[2]').text}")
    message.push("Residence: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[8]/td[2]').text}")
    message.push("Last_login: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[9]/td[2]').text}")
    message.push("Full_profile: #{shorten.short_url} (Sent on PM)")

  rescue NoMethodError
    'No data'
  end
    # FORMATTING AND NESTED IFs BECAUSE DATA FROM THE WEB PAGE CHANGES IF THE PLAYER DECIDES SO
    # WEB SCRAP AIN'T EZ

    if !message.empty?
      message_to_send = " ```Ruby
#{message[0]}
#{message[1]}
#{message[2]}
#{message[3]}
#{message[4]}
#{message[5]}
#{message[7]}"

      if !message[6].nil?
        message_to_send += "
#{message[6] unless message[6][12..-1].match(/\bCET\b/).nil?}```"
      else
        message_to_send += '```'
      end

    else
      '**Couldn\'t find data, maybe check player\'s name?**'
    end
end

bot.run