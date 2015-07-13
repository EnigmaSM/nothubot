# Description:
#   Looks up a MTG card designated by [[brackets]]
#
# Commands:
#   [[CARD_NAME]] - Returns an image of the specified MTG card called CARD_NAME
#
# Notes:
#   The script uses the mtgapi.com API.
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
  robot.hear /\[\[(.*?)\]\]/g, (res) ->
    for cardname in res.match
      cardsingle = cardname.replace '\[\[', ""
      cardsingle = cardsingle.replace '\]\]', ""
      robot.http("http://api.mtgapi.com/v2/cards?name=#{prepURI(cardsingle)}")
        .header('Accept', 'application/json')
        .get() (err, response, body) ->
          if err
            console.log "problems"
            return
          if response.statusCode isnt 200
            console.log "not 200"
            return
          data = null
          try
            data = JSON.parse body
          catch error
           res.send "Ran into an error parsing JSON :("
           return
          if data.cards
            imgUrl = data.cards[0].images.gatherer
            res.send imgUrl
            console.log """
              found a card by name #{data.cards[0].name}
            """
            return
          else
            res.envelope.room = res.envelope.user.name
            textResponse = """
              I couldn't find a MTG card called "#{cardsingle}". Are you sure it's spelled right?
              If you know this is a real card, message @lego
          """
            res.send textResponse
            return
