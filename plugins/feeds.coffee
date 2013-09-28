Q = require 'q'
fs = require 'fs'
config = require '../config/feeds'
readFile = Q.denodeify fs.readFile
writeFile = Q.denodeify fs.writeFile
parseURL = Q.denodeify require('rssparser').parseURL
stateFile = "#{__dirname}/../#{config.stateFile}"
Q.longStackSupport = true

{inspect} = require 'util'

readFeedState = ->
  readFile(stateFile, "utf-8").then (state) -> return Q JSON.parse state

filterItems = (client, lastDate) => (state, item) =>
  pubDate = new Date(item.published_at)
  hearYe client, item, state.feed.channels if pubDate > lastDate
  state.date = Math.max pubDate, state.date
  return state

hearYe = (client, post, channels) ->
  console.log "hear ye, hear ye:", post.title
  channels.forEach (channel) ->
    client.say channel, "[News] #{post.title} - #{post.url}"

checkFeed = (client, feed, state) ->
  date = new Date state[feed.name]
  return parseURL(feed.url)
  .then (json) ->
    return Q json.items.reduce filterItems(client, date), {feed, date}

checkFeeds = (client) -> ->
  console.log "checking feeds..."
  readFeedState().then (state) ->
    feeds = config.feeds.map (feed) -> checkFeed(client, feed, state)

    Q.allSettled(feeds).done (results) ->
      results.filter((p) -> p.state is 'fulfilled').map (result) ->
        state[result.value.feed.name] = result.value.date
          

      return writeFile(stateFile, JSON.stringify(state))
    .done()

module.exports = exports = (client) ->
  setInterval checkFeeds(client), config.checkInterval
  
