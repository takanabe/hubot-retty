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
        .map (w) ->
          "#{w.name} #{w.url}\n #{w.detail}"
        .join '\n\n'

      msg.send message
