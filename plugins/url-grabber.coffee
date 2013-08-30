Q = require 'q'
{extractUrls} = require 'twitter-text'
{exec: yql} = require 'yql'

compact = (array) -> elem for elem in array when elem

extractTitle = (url) ->
  deferred = Q.defer()
  yql "select * from html where url='#{url}' and xpath='//title'", (json) ->
    if json and json.query.results?.title?
      deferred.resolve
        url: url
        title: json.query.results.title
    else
      deferred.reject new Error "no result"

  return deferred.promise

parseUrls = (message) ->
  return Q.allSettled(extractUrls(message).map extractTitle).then (results) ->
    return results.map (result) -> result.value

module.exports = exports =
  message: (from, to, message) ->
    parseUrls(message).done (results) =>
      compact(results).forEach (r) => @say to, "[URL] #{from}: #{r.title} - #{r.url}"
