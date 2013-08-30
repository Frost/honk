Q = require 'q'
fs = require 'fs'
config = require '../config/rksmrgs'
{exec} = require "child_process"

filename = "#{__dirname}/../#{config.outputFile}"

uniq = (value, index, self) -> index is self.indexOf value
sortFile = -> Q.nfcall(exec, "sort -u #{filename} -o #{filename}")
isRksmrgs = (word) ->
  word.toLowerCase().replace(/[^åäö]/g, '').split('').filter(uniq).length is 3
newRksmrgs = (words) ->
  readFile().then (rksmrgsr) ->
    return Q.resolve words.filter (word) ->
      isRksmrgs(word) and word not in rksmrgsr
      

addToFile = (words) ->
  return Q.nfcall(fs.appendFile, filename, words.join("\n") + "\n")
  .then(sortFile).then -> Q "new rksmrgs: #{words.join(", ")}"

readFile = ->
  return Q.nfcall(fs.readFile, filename, "utf-8")
  .then (contents) ->
    return Q contents.toString().split("\n")

getRandomRksmrgs = ->
  return readFile()
  .then (rksmrgsr) ->
    return Q rksmrgsr[Math.floor Math.random() * rksmrgsr.length]

module.exports = exports =
  message: (from, to, message) ->
    if /^!(?:räksmörgås|skaldjursmacka|rÃ¤ksmÃ¶rgÃ¥s)/.test message
      getRandomRksmrgs().done (rksmrgs) => @say to, rksmrgs
    else
      newRksmrgs(message.split(" ")).then (rksmrgsr) ->
        addToFile(rksmrgsr).done console.log if rksmrgsr.length > 0

