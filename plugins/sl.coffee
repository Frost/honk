request = require 'request'
{parseString: parseXml} = require 'xml2js'
Q = require 'q'
config = require '../config/sl'

class SL
  constructor: (options) ->
    @apiKeys = options.apiKeys
    @urls = options.urls

  lookupRoute: (from, to) ->
    Q.all([
      @getSite(from)
      @getSite(to)
    ])
    .spread (from, to) =>
      requestOptions =
        method: "GET"
        url: "#{@urls.reseplanerare}?key=#{@apiKeys.reseplanerare}&S=#{from}&Z=#{to}"
      return Q.nfcall(request, requestOptions)
    .spread (res, xml) ->
      return Q.nfcall(parseXml, xml)
    .then (data) ->
      prefix = "ta"
      output = []
      data.HafasResponse.Trip[0].SubTrip.forEach (subTrip) ->
        output.push "#{prefix} #{subTrip.Transport[0].Name[0]} från #{subTrip.Origin[0]._} #{subTrip.DepartureTime[0]._} mot #{subTrip.Transport[0].Towards[0]} till #{subTrip.Destination[0]._}"
        prefix = "därefter"
      return output.join(",\n")
    .fail (err) ->
      console.log err
      return err

  getSite: (string) ->
    requestOptions =
      method: "GET"
      url: "#{@urls.getSite}?key=#{@apiKeys.getSite}&stationSearch=#{string}"

    return Q.nfcall(request, requestOptions)
    .spread (res, xml) ->
      return Q.nfcall(parseXml, xml)
    .then (data) ->
      return data.Hafas.Sites[0]?.Site[0]?.Number[0]

sl = new SL config

module.exports = exports = (client) ->
  client.addListener 'message', (from, to, message) ->
    if /^!sl \w+ \w+/.test message
      [_, origin, destination] = message.split /\s+/
      sl.lookupRoute(origin, destination).done (output) => @say to, "#{from}: #{output}"

