# DiscordHotBot
DiscordHotBot is a project based on [discordrb](https://github.com/discordrb/discordrb) featuring hot code reloading. It allows to write code on the fly and immediately see the result without having to restart your bot.

## Getting Started
1. Clone this repository and install the dependencies:  
  ```shell
  git clone https://github.com/Oli4242/DiscordHotBot.git <your_project_name>
  cd <your_project_name>
  bundle
  ```
2. Copy your application token in the `token` file
3. Run the bot: `ruby bot.rb`
4. Code :)

## Configuration
The configuration file is `config.yml` (YAML format), open it to know more, it is pretty self explanatory.

The only subtlety is that there are 3 ways to pass the [application token](https://discordapp.com/developers/applications/):
1. From the command line: `ruby bot.rb <token here>`
2. From a file. The `token` file is protected by a `.gitignore` rule that prevents it from being committed by error.
3. From an environment variable. You'll have to edit `config.yml` to enable that.

## Components
A component is the unit of code that gets dynamically (re)loaded by DiscordHotBot.

A Component is a ruby module that extends `DiscordHotBot::Components`. Its name must be the CamelCase version of its file name.
It must be located in the components directory (by default: `components/`) and its file name must end with the components suffix (by default: `.cmp.rb`).

This small convention allows components to be automatically loaded at startup and reloaded when modified. No configuration needed.

Example:

```ruby
# components/ping_pong.cmp.rb
module PingPong                   # CamelCase version of the file name
  extend DiscordHotBot::Component # extends DiscordHotBot::Component

  # normal Discordrb code goes here:

  command :ping do
    "pong!"
  end
end
```

## State
Often you'll want to reload your component code but preserve its runtime state.

DiscordHotBot provides `state`, an [`OpenStruct`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ostruct/rdoc/OpenStruct.html) which can hold any data you want to keep between 2 hot reloads.

The state can be accessed either using `state` or `s`:

```ruby
# components/counter.cmp.rb
module Counter
  extend DiscordHotBot::Component

  command :count do
    s.counter ||= 0 # This variable will preserve its value between 2 code reloads.
    s.counter += 1
    "counter: #{s.counter}"
  end
end
```

## Dependencies
A dependency is a file or a set of files that triggers the reloading of a component when modified:

```ruby
# components/random_quotes/random_quotes.cmp.rb
module RandomQuotes
  extend DiscordHotBot::Component
  depend_on 'quotes.txt'  # This component will be reloaded every time quotes.txt is modified
                          # (the path is expressed relatively to this file).

  quotes = File.read(File.join(__dir__, 'quotes.txt')).lines

  command :quote do
    quotes.sample
  end
end
```

`depend_on` accepts multiple parameters and [file globs](https://ruby-doc.org/core-2.7.0/File.html#method-c-fnmatch):

```ruby
depend_on "file1", "file2", "*.txt"
```

## MIT License
Copyright 2020 Oli4242

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
