# Description:
#   Looks up a stock designated by $STOCK_SYMBOL
#
# Commands:
#   $STOCK_SYMBOL -> Looks up a stock by symbol.
#
# Notes:
#   The script uses the http://dev.markitondemand.com/ API
#
# Author:
#   lego6245

module.exports = (robot) ->
  robot.hear /(^|\s)(\$[a-z\d-]+)/g, (res) ->
    for stockname in res.match
      stocksingle = stockname.replace '$', ""
      robot.http("http://dev.markitondemand.com/Api/v2/Quote/json?symbol=#{stocksingle}")
        .header('Accept', 'application/json')
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
              I couldn't find a stock by symbol "#{stocksingle}". Are you sure it's spelled right?
              If you know this is a real stock, message @lego
            """
            res.send textResponse
            return
          data = null
          try
            data = JSON.parse body
          catch error
           res.send "Ran into an error parsing JSON :("
           return
          if data.Status = "SUCCESS"
            isGain = "gain"
            if(data.Change < 0)
              isGain = "loss"
            textResponse = """
              #{data.Name} (#{data.Symbol}) is trading at #{data.LastPrice}, which is a #{isGain} of #{data.Change} on the trading day.
            """
            res.send textResponse
            console.log """
            found a stock by name #{data.Symbol}
            """
            return
          else
            res.envelope.room = res.envelope.user.name
            textResponse = """
              I couldn't find a stock by symbol "#{stocksingle}". Are you sure it's spelled right?
              If you know this is a real stock, message @lego
            """
            res.send textResponse
            return
