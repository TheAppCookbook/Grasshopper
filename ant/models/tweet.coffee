# Imports
Twitter = require "twitter"
Parse = require("parse").Parse


Tweet = Parse.Object.extend "Tweet"

# Class Properties  
Tweet.client = new Twitter
    consumer_key: "AuIeip7tJbQec6W1jp5EEaGaL"
    consumer_secret: "QM7O2qHuI08YT5heU6wJc0rkxCZNpvqxRGWIrVR0cIyHbhvyDP"
    access_token_key: "10125612-qTock7QLLQjhc2UdlIVIRoGPBAN1fTAHZaVhdFMfU"
    access_token_secret: "EPWE4lhyTjzBqjkk9oVe92QMirvlz0pygQudg7wNzrVp9"
    
# Class Accessors
Tweet.stream = (filterData, handler) ->
    Tweet.client.stream "statuses/filter", filterData, (stream) ->
        stream.on "data", (tweetData) ->
            handler(new Tweet tweetData)
        
module.exports = Tweet
