module.exports = exports = (client) ->
  client.addListener 'message', (from, to, message) ->
    console.log "#{from} #{to}: #{message}"

