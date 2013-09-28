request = require 'request'
Q = require 'q'
config = require '../config/github'

class GitHub
  constructor: (options) ->
    @apiKey = options.apiKey
    @url = options.url
    @prefix = options.prefix
    @issue_regex = new RegExp config.regexen.issue
    @repo_regex = new RegExp config.regexen.repo
    @user_regex = new RegExp config.regexen.user

  perform: (to, message) ->
    if @issue_regex.test message
      @_prepareRequest @_getIssue, @issue_regex, message, 1, 4
    else if @repo_regex.test message
      @_prepareRequest @_getRepo, @repo_regex, message, 1, 4
    else if @user_regex.test message
      @_prepareRequest @_getUser, @user_regex, message, 1, 2
    else return Q ""

  _getIssue: (owner, repo, issue) =>
    return @_githubRequest("repos/#{owner}/#{repo}/issues/#{issue}")
    .then (json) => "#{@prefix} #{json.title} | #{json.html_url}"

  _getRepo: (owner, repo) =>
    return @_githubRequest("repos/#{owner}/#{repo}")
    .then (json) => "#{@prefix} #{json.full_name} - #{json.description} | #{json.html_url}"

  _getUser: (user) =>
    return @_githubRequest("users/#{user}")
    .then (json) => "#{@prefix} #{json.name} | #{json.html_url}"

  _prepareRequest: (method, regex, message, start, end) ->
    return method(regex.exec(message).slice(start, end)...)

  _githubRequest: (url) ->
    return Q.nfcall(request, requestOptions "#{@url}/#{url}")
    .spread (res, data) -> return JSON.parse data

requestOptions = (url) ->
  url: url
  method: "GET"
  headers:
    "User-Agent": "Honk IRC-bot"

gh = new GitHub config
module.exports = exports = (client) ->
  client.addListener 'message', (from, to, message) ->
    gh.perform(to, message).done (output) => @say to, output

