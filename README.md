# Hubot Alternative Twitter Adapter

## Description

This is an alternative [Twitter](http://twitter.com) adapter for hubot that allows you to
send a tweet to your hubot and send tweet back with the response.

It can also configure the adapter to only respond to whitelisted users. This requires that the `roles.coffee` script
is enabled and configured. The value of the `HUBOT_SELECTIVE_ROLE` environment variable will restrict the adapter to
only process messages from user with that role.

## Installation

* Add `hubot-twitter` as a dependency in your hubot's `package.json`
* Install dependencies with `npm install`
* Run hubot with `bin/hubot -a twitter -n the_name_of_the_twitter_bot_account`

### Note if running on Heroku

You will need to change the process type from `app` to `web` in the `Procfile`.

## Usage

You will need to set some environment variables to use this adapter.

### Heroku

    % heroku config:add HUBOT_TWITTER_KEY="key"
    % heroku config:add HUBOT_TWITTER_SECRET="secret"
    % heroku config:add HUBOT_TWITTER_TOKEN="token"
    % heroku config:add HUBOT_TWITTER_TOKEN_SECRET="secret"
    % heroku config:add HUBOT_SELECTIVE_ROLE="approved follower"

### Non-Heroku environment variables

    % export HUBOT_TWITTER_KEY="key"
    % export HUBOT_TWITTER_SECRET="secret"
    % export HUBOT_TWITTER_TOKEN="token"
    % export HUBOT_TWITTER_TOKEN_SECRET="secret"
    % export HUBOT_SELECTIVE_ROLE="approved follower"

##TODO

* Respond to direct messages with direct replies


## Contribute

Just send pull request if needed or fill an issue !

## Copyright

Copyright © Michael McHugh. See LICENSE for details.

