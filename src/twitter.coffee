# Hubot dependencies
{Robot, Adapter, TextMessage, EnterMessage, LeaveMessage, Response} = require 'hubot'

HTTPS = require 'https'
EventEmitter = require('events').EventEmitter
oauth = require('oauth')

class Twitter extends Adapter

  send: (envelope, strings...) ->
    @robot.logger.info "Sending strings to user: #{envelope.user.name} (#{envelope.user.id})"
    #Envelope has the properties room, message, user

    strings.forEach (str) =>
      text = str
      tweetsText = str.split('\n')
      tweetsText.forEach (tweetText) =>
        @bot.send envelope.user.name, envelope.message.id, tweetText

  reply: (envelope, strings...) ->
    @robot.logger.info "Replying to user: #{envelope.user.name} (#{envelope.user.id})"
    strings.forEach (text) =>
      console.log text
      @bot.send envelope.user.name, envelope.message.id, text

  command: (command, strings...) ->
    @robot.logger.info "Command: #{command}"
    @bot.send command, strings...

  run: ->
    self = @

    options =
      key: process.env.HUBOT_TWITTER_KEY
      secret: process.env.HUBOT_TWITTER_SECRET
      token: process.env.HUBOT_TWITTER_TOKEN
      tokensecret: process.env.HUBOT_TWITTER_TOKEN_SECRET

    @selective = process.env.HUBOT_SELECTIVE_ROLE
    @robot.logger.debug "Selective Role: #{@selective}"

    bot = new TwitterStreaming(@robot, options)

    bot.tweet @robot.name, (data, err) =>
      if err
        @robot.logger.warning "received error: #{err}"
        return

      reg = new RegExp "@#{@robot.name}", 'i'
      @robot.logger.debug "received #{data.text} from #{data.user.screen_name}"

      message = data.text.replace reg, @robot.name
      user = @robot.brain.userForId data.user.id_str, name: data.user.screen_name, room: "Twitter"
      theMessage = new TextMessage user, message, data.id_str
      @robot.logger.debug "hubot command: #{message}"
      @robot.logger.debug theMessage
      @receive theMessage

    @bot = bot

    @emit "connected"

exports.use = (robot) ->
  new Twitter robot


class TwitterStreaming extends EventEmitter

  self = @
  constructor: (@robot, options) ->
    if options.token? and options.secret? and options.key? and options.tokensecret?
      @token = options.token
      @secret = options.secret
      @key = options.key
      @domain = 'stream.twitter.com'
      @tokensecret = options.tokensecret
      @consumer = new oauth.OAuth "https://twitter.com/oauth/request_token",
        "https://twitter.com/oauth/access_token",
        @key,
        @secret,
        "1.0A",
        "",
        "HMAC-SHA1"
    else
      throw new Error("Not enough parameters provided. I need a key, a secret, a token, a secret token")

  tweet: (track, callback) ->
    @post "/1.1/statuses/filter.json?track=#{track}", '', callback

  send: (user, status_id, tweetText) ->
    @robot.logger.info "send twitt to #{user} with text #{tweetText} in response to #{status_id}"
    @robot.logger.debug { status: "@#{user} #{tweetText}", in_reply_to_status_id: status_id }
    @consumer.post "https://api.twitter.com/1.1/statuses/update.json", @token, @tokensecret, { status: "@#{user} #{tweetText}", in_reply_to_status_id: status_id }, 'UTF-8', (error, data, response) =>
      if error
        @robot.logger.warn "twitter send error: #{error} #{data}"
      @robot.logger.debug "Status #{response.statusCode}"
      @robot.logger.debug "Data:"
      @robot.logger.debug data

  # Convenience HTTP Methods for posting on behalf of the token"d user
  get: (path, callback) ->
    @request "GET", path, null, callback

  post: (path, body, callback) ->
    @request "POST", path, body, callback

  request: (method, path, body, callback) ->
    @robot.logger.debug "https://#{@domain}#{path}, #{@token}, #{@tokensecret}, null"

    request = @consumer.get "https://#{@domain}#{path}", @token, @tokensecret, null

    request.on "response", (response) ->
      response.on "data", (chunk) ->
        parseResponse chunk + '', callback

      response.on "end", (data) ->
        @robot.logger.debug 'end request'

      response.on "error", (data) ->
        @robot.logger.debug 'error ' + data

    request.end()

  parseResponse = (data, callback) =>
    while ((index = data.indexOf('\r\n')) > -1)
      json = data.slice(0, index)
      data = data.slice(index + 2)

      if json.length > 0
        try
          callback JSON.parse(json), null
        catch err
          @robot.logger.error json
