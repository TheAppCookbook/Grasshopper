# Imports
Twitter = require "twitter"
Parse = require("parse").Parse
Story = require "./story"


Tweet = Parse.Object.extend "Tweet", {
    # Mutator
    destroyWithCascade: () ->
        self = this
        
        Story.forTweet this, (story) ->
            console.log("destroying tweet", self.get("tweetID"))
            self.destroy
                success: () ->
                    story.tweets (tweets) ->
                        if tweets.length == 0
                            story.destroy()
                            console.log("destroying story", story.get("title"))
}, {
    # Class Properties  
    client: new Twitter
        consumer_key: "AuIeip7tJbQec6W1jp5EEaGaL"
        consumer_secret: "QM7O2qHuI08YT5heU6wJc0rkxCZNpvqxRGWIrVR0cIyHbhvyDP"
        access_token_key: "10125612-qTock7QLLQjhc2UdlIVIRoGPBAN1fTAHZaVhdFMfU"
        access_token_secret: "EPWE4lhyTjzBqjkk9oVe92QMirvlz0pygQudg7wNzrVp9"
    
    # Initializers    
    fromTweetData: (tweetData) ->        
        tweet = new Tweet
        tweet.set "tweetID", tweetData.id_str
        tweet.set "isBreaking", tweetData.text.indexOf("#BREAKING") == 0
        tweet.set "mediaURL", tweetData.entities?.media?[0]?.media_url or null
    
        return tweet
    
    # Class Accessors
    stream: (filterData, handler) ->
        Tweet.client.stream "statuses/filter", filterData, (stream) ->
            stream.on "data", (tweetData) ->
                handler(tweetData)
                
    find: (attrs, callback) ->
        query = new Parse.Query Tweet
        for key, val of attrs
            console.log(key, val)
            query.equalTo key, val
        query.find
            success: (tweets) ->
                callback(tweets)
            error: () ->
                callback(null)
}
        
module.exports = Tweet
