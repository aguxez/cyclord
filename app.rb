require 'mechanize'
require 'pp'
require 'discordrb'
require 'dotenv/load'

mechanize = Mechanize.new

bot = Discordrb::Commands::CommandBot.new token: ENV['DISCORD'], client_id: '250138918282985473', prefix: '!!'

bot.command :player do |event|
  content = event.message.content.split(' ')
  player_name = content[1]
  message = []

  begin
    # name from the message sent to the bot
    page = mechanize.get("https://secure.tibia.com/community/?subtopic=characters&name=#{player_name}")

    # Yes, these are all pushes to an array so I don't gate rate limited on discord and this way I can
    # Format the code nicely :-)
    # These are all xPaths from the Tibia website.
    message.push("Name: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[2]/td[2]').text}")
    message.push("Sex: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[3]/td[2]').text}")
    message.push("Vocation: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[4]/td[2]').text}")
    message.push("Level: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[5]/td[2]').text}")
    message.push("World: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[7]/td[2]').text}")
    message.push("Residence: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[8]/td[2]').text}")
    message.push("Last login: #{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[9]/td[2]').text}")

  rescue NoMethodError
    'Couldn\'t find data, maybe check your spelling?'
  end

    if !message.empty?
      " ```
      #{message[0]}
      #{message[1]}
      #{message[2]}
      #{message[3]}
      #{message[4]}
      #{message[5]}
      #{message[6]}
      ``` "
    else
      'Couldn\'t find data, maybe check player\'s name?'
    end
end

bot.run