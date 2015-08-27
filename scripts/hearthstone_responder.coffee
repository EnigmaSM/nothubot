# Description:
#   Looks up a Hearthstone card designated by {{curly braces}}
#
# Commands:
#   {{CARD_NAME}} - Returns an image of the specified Hearthstone card called CARD_NAME
#   {{*CARD_NAME}} - Returns the animated / gold image of the specified Hearthstone card called CARD_NAME
#
# Notes:
#   The script uses the heartstone api exposed by mashery.
#
# Author:
#   lego6245

prepURI = (string) ->
  submission = encodeURI(string)
  submission = replaceSmartQuotes(submission)
  return submission

replaceSmartQuotes = (string) ->
  newVal = string.replace ///%E2%80%98///g, "\'"
  newVal = newVal.replace ///%E2%80%99///g, "\'"
  newVal = newVal.replace ///%E2%80%9A///g, "\'"
  newVal = newVal.replace ///%E2%80%9B///g, "\'"
  newVal = newVal.replace ///%E2%80%9C///g, "\""
  newVal = newVal.replace ///%E2%80%9D///g, "\""
  newVal = newVal.replace ///%E2%80%9E///g, "\""
  newVal = newVal.replace ///%E2%80%9F///g, "\""
  return newVal

module.exports = (robot) ->
  robot.hear /\{\{(.*?)\}\}/g, (res) ->
    for cardname in res.match
      setGold = false
      cardsingle = cardname.replace '\{\{', ""
      cardsingle = cardsingle.replace '\}\}', ""
      if cardsingle[0] is '*'
        setGold = true
        cardsingle = cardsingle.replace '*', ""
      robot.http("https://omgvamp-hearthstone-v1.p.mashape.com/cards/search/#{prepURI(cardsingle)}?collectible=1")
        .header('Accept', 'application/json')
        .header('X-Mashape-Key', process.env.HUBOT_MASHAPE_KEY) # process.env.HUBOT_MASHAPE_KEY
        .get() (err, response, body) ->
          if err
            res.envelope.room = res.envelope.user.name
            textResponse = """
              I ran into some hardcore problems. Let @lego know.
          """
            res.send textResponse
            return

          if response.statusCode isnt 200
            res.envelope.room = res.envelope.user.name
            textResponse = """
              I couldn't find a Hearthstone card called "#{cardsingle}". Are you sure it's spelled right?
              If you know this is a real card, message @lego
          """
            res.send textResponse
            return
          data = null
          try
            data = JSON.parse body
          catch error
           res.send "Ran into an error parsing JSON :("
           return
          if data[0]
            imgUrl = ""
            if setGold
              imgUrl = data[0].imgGold
            else
              imgUrl = data[0].img
            res.send imgUrl
            console.log """
              found a card by name #{data[0].name}
            """
            return
          else
            res.envelope.room = res.envelope.user.name
            textResponse = """
              I couldn't find a Hearthstone card called "#{cardsingle}". Are you sure it's spelled right?
              If you know this is a real card, message @lego
          """
            res.send textResponse
            return
