#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

# Author: KayMW

# Copyright © 2017 KayMW <RedL0tus@users.noreply.github.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the LICENSE file for more details.

require 'yaml'
require 'rubygems'
require 'bundler/setup'
require_relative 'libs/telegram_bot_api.rb'
require_relative 'libs/telegram_json_generator.rb'
require_relative 'libs/telegram_bot_message.rb'

configfile = File.open('config.yml')
bot = Telegram_bot::Api.new(YAML.load(configfile)["bot"]["token"])

offset = -1

class SaltedFishBot
    def initialize(*targets)
        @targets = targets
    end

    def self.message_parser(message)
        print(message["message"]["text"])
        return "Emmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm"
    end
end

while true
    response = Telegram_bot::Message.new(bot.get_updates(offset))
    if (response.parse["ok"] == true)
        response.parse["result"].map do |message|
            bot.send_json("sendMessage",Telegram_bot::Json_generator.generate_json(chat_id: message["message"]["chat"]["id"],reply_to_message_id: message["message"]["message_id"],text: SaltedFishBot.message_parser(message),parse_mode: "markdown"))
            offset = message["update_id"] + 1
        end
    end
end