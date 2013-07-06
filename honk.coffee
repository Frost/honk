irc = require 'irc'
config = require './config'

class Honk
  constructor: (opts) ->
    @client = new irc.Client opts.server, opts.nick, channels: opts.channels

  use: (plugin) -> @client.addListener event,handler for event,handler of plugin
  all: (plugins) -> @use require("./plugins/#{plugin}") for plugin in plugins

honk = new Honk config.client
honk.all config.plugins
