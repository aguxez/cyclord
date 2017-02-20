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
  colors = %w(#FC4E29 #55D511 #1298DF #3523B4 #D678EB)
  embed_colors = rand(1...colors.length + 1)

  begin
    # name from the message sent to the bot
    page = mechanize.get("https://secure.tibia.com/community/?subtopic=characters&name=#{player_name}")
    shorten = Bitly.client.shorten("https://secure.tibia.com/community/?subtopic=characters&name=#{player_name}")

    # Yes, these are all pushes to an array so I don't gate rate limited on discord and this way I can
    # Format the message nicely :-)
    # These are all xPaths from the Tibia website.
    message.push("#{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[2]/td[2]').text}")
    message.push("#{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[3]/td[2]').text}")
    message.push("#{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[4]/td[2]').text}")
    message.push("#{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[5]/td[2]').text}")
    message.push("#{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[7]/td[2]').text}")
    message.push("#{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[8]/td[2]').text}")
    message.push("#{page.at('//*[@id="characters"]/div[5]/div/div/table[1]/tr[9]/td[2]').text}")

  rescue NoMethodError
    'No data'
  end
    # CHANGED IFS STATEMENTS FOR EMBEDDED MESSAGE, LOOKS NICER AND HAS LINKS
    if !message.empty?
      event.channel.send_embed do |embed|
        embed.message = { text: "**#{message[0]}**, #{message[1]} #{message[2]}, **level #{message[3]}**
        from **#{message[4]}** and resides in **#{message[5]}**" }
        embed.color = colors[embed_colors]
        embed.author = { name: player_name_pm, icon_url: event.user.avatar_url}
        embed.url = shorten.short_url
        embed.thumbnail = { url: event.user.avatar_url }
      end
    else
      '**Couldn\'t find data, maybe check player\'s name?**'
    end
end

bot.run
