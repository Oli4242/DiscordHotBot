module CountExample
  extend DiscordHotBot::Component

  command :count do
    s.count ||= 0
    s.count += 1
    "count: #{s.count}"
  end
end
