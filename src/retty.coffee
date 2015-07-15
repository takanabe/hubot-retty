# Description
#   A hubot script that provide information listed in Retty wanna go lists.
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot retty  - Display Retty wanna go list.
#   hubot retty cancel username - Add a username to today's lunch attendee_list.
#   hubot retty join username - Add a username to today's lunch attendee_list.
#   hubot retty show attendees - Display attendees' name.
#   hubot retty select number - Display restaurant detailed information.
#   hubot retty select random - Display restaurant detailed information randomly.
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Takayuki WATANABE <takanabe.w@gmail.com>

client = require('cheerio-httpcli')

module.exports = (robot) ->

  robot.respond /retty$/i, (msg) ->
    # send HTTP request
    base_url = 'http://user.retty.me/105513/ikitai/ARE13'
    client.fetch base_url, {}, (err, $, res) ->
      wannago_lists = []
      # parse response body
      $('.my_wish_list .restaurant_name_section a').each ()->
        url = $(this).attr('href')
        name = $(this).text()
        information_list = []
        $(this).parents('.restaurant_title_area').children('.restaurant_info_section').find('a').each ()->
          restaurant_info = $(this).text()
          # console.log restaurant_info
          information_list.push restaurant_info

        detail = information_list.join()
        wannago_lists.push {url, name, detail}
      # filter wanna go lists
      filtered = wannago_lists.filter (w) ->
        if query? then w.name.match(new RegExp(query, 'i')) else true

      # format wanna go lists
      message = filtered
        .map (w,id) ->
          "#{id}: #{w.name} #{w.url}\n #{w.detail}"
        .join '\n\n'

      msg.send message

  robot.respond /retty\sselect\s(\d+)$/i, (msg) ->
    # send HTTP request
    base_url = 'http://user.retty.me/105513/ikitai/ARE13'
    client.fetch base_url, {}, (err, $, res) ->
      wannago_lists = []
      # parse response body
      $('.my_wish_list .restaurant_name_section a').each ()->
        url = $(this).attr('href')
        wannago_lists.push url

      client.fetch wannago_lists[msg.match[1]], {}, (err, $, $res) ->
        # $('#restaurant-info-retty .table-type-1 tbody tr').each ()->
        content_list = []
        $('#restaurant-info-retty .table-type-1 tr').each ()->
           th = $(this).find('th').text()
           content = th

           if th == "店名"
             content = "+#{content}:#{$(this).find('td .font-md').text()}"
             content_list.push content
           else if th == "ジャンル"
             content = "+#{content}:#{$(this).find('td').text()}"
             content_list.push content
           else if th == "アクセス"
             content = "+#{content}:#{$(this).find('td p span').text()}"
             content_list.push content
           else if th == "住所"
             content = "+#{content}:#{$(this).find('td p').text()}"
             content_list.push content.replace(/\s+/g,"")
           else if th == "営業時間"
             content = "+#{content}:#{$(this).find('td time').text()}"
             content_list.push content.replace(/\s+/g,"")
           else if th == "定休日"
             content = "+#{content}:#{$(this).find('td').text()}"
             content_list.push content.replace(/\s+/g,"")
           else if th == "電話番号"
             content = "+#{content}:#{$(this).find('td').text()}"
             content_list.push content

        msg.send content_list.join '\n'

  robot.respond /retty\sselect\srandom$/i, (msg) ->
    # send HTTP request
    base_url = 'http://user.retty.me/105513/ikitai/ARE13'
    client.fetch base_url, {}, (err, $, res) ->
      wannago_lists = []
      # parse response body
      $('.my_wish_list .restaurant_name_section a').each ()->
        url = $(this).attr('href')
        wannago_lists.push url

      client.fetch wannago_lists[Math.floor( Math.random() *  wannago_lists.length)], {}, (err, $, $res) ->
        # $('#restaurant-info-retty .table-type-1 tbody tr').each ()->
        content_list = []
        $('#restaurant-info-retty .table-type-1 tr').each ()->
           th = $(this).find('th').text()
           content = th

           if th == "店名"
             content = "+#{content}:#{$(this).find('td .font-md').text()}"
             content_list.push content
           else if th == "ジャンル"
             content = "+#{content}:#{$(this).find('td').text()}"
             content_list.push content
           else if th == "アクセス"
             content = "+#{content}:#{$(this).find('td p span').text()}"
             content_list.push content
           else if th == "住所"
             content = "+#{content}:#{$(this).find('td p').text()}"
             content_list.push content.replace(/\s+/g,"")
           else if th == "営業時間"
             content = "+#{content}:#{$(this).find('td time').text()}"
             content_list.push content.replace(/\s+/g,"")
           else if th == "定休日"
             content = "+#{content}:#{$(this).find('td').text()}"
             content_list.push content.replace(/\s+/g,"")
           else if th == "電話番号"
             content = "+#{content}:#{$(this).find('td').text()}"
             content_list.push content

        msg.send content_list.join '\n'

  KEY_RETTY = 'retty'

  # Slackのユーザ名から自動的に取得したい
  robot.respond /retty\sjoin\s(.+)$/i, (msg) ->
    name  = msg.match[1]
    attendee_list = (robot.brain.get KEY_RETTY) ? []
    attendee_list.push name

    robot.brain.set KEY_RETTY, attendee_list

    msg.send "本日のランチに#{attendee_list[attendee_list.length-1]}が参加します!!\n参加者は#{attendee_list}になりました"

  robot.respond /retty\scancel\s(.+)$/i, (msg) ->
    name  = msg.match[1]
    attendee_list = (robot.brain.get KEY_RETTY) ? []
    attendee_list.splice(attendee_list.indexOf(name),1)

    robot.brain.set KEY_RETTY, attendee_list
    msg.send "#{name}がランチに参加できなくなりましたorz\n参加者は#{attendee_list}になりました"

  robot.respond /retty\sshow\sattendees$/i, (msg) ->
    attendee_list = (robot.brain.get KEY_RETTY) ? []

    msg.send "今日のランチ参加者は#{attendee_list}です!!"
