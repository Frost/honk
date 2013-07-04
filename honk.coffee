irc = require 'irc'
config = require './config'

class Hink
  constructor: (opts) ->
    @client = new irc.Client opts.server, opts.nick, channels: opts.channels

  use: (plugin) -> @client.addListener event,handler for event,handler of plugin
  all: (plugins) -> @use require("./plugins/#{plugin}") for plugin in plugins

hink = new Hink config.client
hink.all config.plugins
