Q = require 'q'
fs = require 'fs'
config = require '../config/rksmrgs'
{exec} = require "child_process"

Q.longStackSupport = true

isRksmrgs = (word) ->
  word.toLowerCase().replace(/[^åäö]/g, '').split('').sort().join('').replace(/(.)\1*/g, "$1") is "äåö"

addToFile = (words) ->
  filename = "#{__dirname}/../#{config.outputFile}"
  return Q.nfcall(fs.appendFile, filename, words.join("\n") + "\n")
  .then =>
    return Q.nfcall(exec, "sort -u #{filename} -o #{filename}")
  .then ->
    return Q words

parseRksmrgsr = (message) ->
  rksmrgsr = []
  message.split(" ").forEach (word) -> rksmrgsr.push word if isRksmrgs word
  if rksmrgsr.length > 0
    return addToFile rksmrgsr
  else
    return Q.reject("")

module.exports = exports =
  message: (from, to, message) ->
    if /^!räksmörgås/.test message
      @say to, randomRksmrgs
    else
      parseRksmrgsr(message)
      .done (words) ->
        console.log "new rksmrgs: #{words}"
