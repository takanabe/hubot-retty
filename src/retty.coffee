# Description
#   A hubot script that provide information listed in Retty wanna go lists.
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Takayuki WATANABE <takanabe.w@gmail.com>

cheerio = require 'cheerio'
request = require 'request'

module.exports = (robot) ->

  robot.respond /retty$/i, (msg) ->

    # send HTTP request
    base_url = 'http://user.retty.me/105513/ikitai/ARE13'
    request base_url, (_, res) ->

      # parse response body
      $ = cheerio.load res.body
      wannago_lists = []
      $('.my_wish_list .restaurant_name_section a').each ->
        a = $ @
        url =  a.attr('href')
        name = a.text()
        wannago_lists.push { url, name }

      # filter wanna go lists
      filtered = wannago_lists.filter (w) ->
        if query? then w.name.match(new RegExp(query, 'i')) else true

      # format wanna go lists
      message = filtered
        .map (w) ->
          "#{w.name} #{w.url}"
        .join '\n'

      msg.send message
