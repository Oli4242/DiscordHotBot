module QuotesExample
  extend DiscordHotBot::Component

  depend_on 'quotes.txt'

  quotes = File.read(File.join(__dir__, 'quotes.txt')).lines

  command :quote do
    quotes.sample
  end
end
