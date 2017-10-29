#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

# Author: KayMW

# Copyright © 2017 KayMW <RedL0tus@users.noreply.github.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the LICENSE file for more details.

require 'uri'
require 'yaml'
require 'logger'
require 'rbconfig'
require 'rubygems'
require 'net/http'
require 'bundler/setup'
require_relative 'libs/telegram_bot/api.rb'
require_relative 'libs/telegram_bot/json_generator.rb'
require_relative 'libs/telegram_bot/message.rb'

class SaltedFishBot
    def initialize(token)
        @log = Logger.new(STDOUT)
        @tg_bot = Telegram_bot::Api.new(token)
        @tg_offset = -1
        if RbConfig::CONFIG['target_os'] == 'mswin32'
            @div = "\\"
        else
            @div = "/"
        end
    end

    def caption(msg)
        text = msg["message"]["text"].split
        while text.length < 3
            return "<b>Usage:</b> <code>/caption@SaltedFishBot &lt;image URI&gt; &lt;caption&gt;</code> ."
        end
        if (text[1] =~ /^[hH][tT][tT][pP]([sS]?):\/\/(\S+\.)+\S{2,}\.(jpg|jpeg|png)/)
            uri = URI(text[1])

            # TODO: Determine file size.
            #Net::HTTP.start(uri.host, uri.port) do |http|
            #    img_head = http.request_head(text[1])
            #end
            #return "Image size: #{img_head["content-length"]}"
        else
            return "Invalid URI, only support PNG and/or JPEG files."
        end
        return "Invalid request."
    end

    def msg_parser(msg)
        case msg["message"]["text"]
        when /\/caption/
            return caption(msg)
        else
            return "<i>Invalid request</i>"
        end
    end

    def start()
        @log.info(">>> Bot started.")
        while true
            response = Telegram_bot::Message.new(@tg_bot.get_updates(@tg_offset))
            if (response.parse["ok"] == true)
                response.parse["result"].map do |msg|
                    if ((msg["message"] != nil) && (msg["message"] != []) && (msg["message"] != ""))
                        @log.info(">>> Got a message from #{msg["message"]["from"]["id"]} @chat#{msg["message"]["chat"]["id"]}: #{msg["message"]["text"]}")
                        res = msg_parser(msg)
                        if ((res != nil) && (res != "") && (res != []))
                            @tg_bot.send_json("sendMessage",Telegram_bot::Json_generator.generate_json(chat_id: msg["message"]["chat"]["id"],reply_to_message_id: msg["message"]["message_id"],text: res,parse_mode: "html"))
                        end
                    end
                    @tg_offset = msg["update_id"] + 1
                end
            end
        end
    end
end

configfile = File.open('config.yml')
bot = SaltedFishBot.new(YAML.load(configfile)["bot"]["token"])
bot.start()