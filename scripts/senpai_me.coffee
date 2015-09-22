# Description:
#   Gives you a s-senpai link generated through the channel
#
# Commands:
#   hubot senpai me: Returns a link that was scraped from s-senpai.
#
# Notes:
#   This really isn't extendable.
#
# Author:
#   lego6245

module.exports = (robot) ->
  robot.hear /http/i, (res) ->
    if res.envelope.room is "shitposting"
      splits = res.match.input.split(" ")
      if splits.length is 1
        if ! robot.brain.data.senpais
          robot.brain.data.senpais = []
        robot.brain.data.senpais.push splits[0]
  robot.respond /senpai me/i, (res) ->
    res.send res.random robot.brain.data.senpais
