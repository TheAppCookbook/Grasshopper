# Imports
Twitter = require "twitter"
Parse = require("parse").Parse
Story = require "./story"
pos = require "pos"


Tweet = Parse.Object.extend "Tweet", {
    # Accessors
    keywords: () ->
        # https://github.com/dariusk/pos-js
        
        taggedWords = Tweet._tagger.tag(Tweet._lexer.lex(@get("text")))
        longEnoughWords = taggedWords.filter ($0) ->
            return $0[0].length > 3
        
        keywords = longEnoughWords.filter ($0) ->
            return [
                "IN", "DT", "CC", "CD",
                "VB", "VBD", "VBN", "VBP", "VBZ",
                "RB", "RBR", "RBS",
                "SYM", "TO", "UH",
                "WDT", "WP", "WP$", "WRB",
                ",", ".", ":", "\"", "(", ")"
            ].indexOf($0[1]) == -1
            
        return keywords.map ($0) ->
            return $0[0].toLowerCase()
            
    proximityToTweet: (anotherTweet) ->
        thisKeywords = @keywords()
        otherKeywords = anotherTweet.keywords()
        
        matches = thisKeywords.filter ($0) ->
            otherKeywords.indexOf($0) != -1
        
        return matches.length / otherKeywords.length
    
    # Mutators
    destroyWithCascade: () ->
        self = this
        
        Story.forTweet this, (story) ->
            success: () ->
                story.tweets (tweets) ->
                    destroyStory = tweets.indexOf(self) == 0
                    
                    console.log("destroying tweet", self.get("tweetID"))
                    self.destroy
                    
                    if destroyStory
                        story.destroy()
                        console.log("destroying story", story.get("title"))
}, {
    # Class Properties
    _client: new Twitter
        consumer_key: "AuIeip7tJbQec6W1jp5EEaGaL"
        consumer_secret: "QM7O2qHuI08YT5heU6wJc0rkxCZNpvqxRGWIrVR0cIyHbhvyDP"
        access_token_key: "10125612-qTock7QLLQjhc2UdlIVIRoGPBAN1fTAHZaVhdFMfU"
        access_token_secret: "EPWE4lhyTjzBqjkk9oVe92QMirvlz0pygQudg7wNzrVp9"
        
    _lexer: new pos.Lexer
    _tagger: new pos.Tagger
    
    # Initializers
    fromTweetData: (tweetData) ->
        if tweetData.text?.indexOf("@") == 0
            console.log("invalid: direct @-mention", tweetData.text)
            return null
        else if tweetData.text?.indexOf("RT @GrasswireNow") == 0
            console.log("invalid: RT @GrasswireNow", tweetData.text)
            return null
        
        tweet = new Tweet
        tweet.set "tweetID", tweetData.id_str
        tweet.set "isBreaking", tweetData.text.indexOf("#BREAKING") != -1
        tweet.set "mediaURL", tweetData.entities?.media?[0]?.media_url or null
        tweet.set "text", tweetData.text
        
        return tweet
    
    # Class Accessors
    stream: (filterData, handler) ->
        Tweet._client.stream "statuses/filter", filterData, (stream) ->
            stream.on "data", (tweetData) ->
                handler(tweetData)
                
    find: (attrs, callback) ->
        query = new Parse.Query Tweet
        for key, val of attrs
            query.equalTo key, val
        query.find
            success: (tweets) ->
                callback(tweets)
            error: () ->
                callback(null)
}
        
module.exports = Tweet
