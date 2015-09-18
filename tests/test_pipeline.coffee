# Imports
Parse = require("parse").Parse
Tweet = require("../models/tweet")
Story = require("../models/story")
processTweet = require("../ant")

# Setup
Parse.initialize "yXnvhnBXI1e3Jv7xCYMD7fBCxRr4S7eoRNp7MpDA",
    "YVqvr62I12ONw1FIPm2IdFEs2rxFWgw8T7c9OJ2o"

Tweets = [
    # initial tweet
    {
        text: "#BREAKING: Senate Democrats block resolution against #IranDeal for the third time - @MBowmanVOA",
        id_str: "644548329586737153",
        expectation: (test, callback) ->
            query = new Parse.Query "Story"
            query.equalTo "title", @text
            query.find().then (stories) ->
                test.equal stories.length, 1
                callback()
    },
    
    # initial tweet
    {
        text: "RT @CNBCnow: BREAKING: Widespread ground stops for American Airlines nationwide » http://t.co/hGmDt8wW80",
        id_str: "644559879471017985",
        expectation: (test, callback) ->
            query = new Parse.Query "Story"
            query.equalTo "title", @text
            query.find().then (stories) ->
                test.equal stories.length, 1
                callback()
    },
    
    # duplicate tweet
    {
        text: "RT @CNBCnow: BREAKING: Widespread ground stops for American Airlines nationwide » http://t.co/hGmDt8wW80",
        id_str: "644559879471017985",
        expectation: (test, callback) ->
            query = new Parse.Query "Story"
            query.equalTo "title", @text
            query.find().then (stories) ->
                test.equal stories.length, 1
                callback()
    },
    
    # associated tweet
    {
        text: "RT @MatthewKeysLive: American Airlines spokesperson tells me “technical issues” are causing flights to be grounded nationwide.",
        id_str: "644563684425994240",
        expectation: (test, callback) ->
            query = new Parse.Query "Tweet"
            query.equalTo "text", @text
            query.find().then (tweets) ->
                test.equal tweets.length, 1
                callback()
    },
    
    # associated tweet
    {
        text: "RT @grasswire: American Airlines grounds flights in U.S. over “technical glitch,” airliner confirms to Grasswire - http://t.co/2dHMbbit7M",
        id_str: "644566082443943936",
        expectation: (test, callback) ->
            query = new Parse.Query "Tweet"
            query.equalTo "text", @text
            query.find().then (tweets) ->
                test.equal tweets.length, 1
                callback()
    },
    
    # unassociated tweet
    {
        text: "NWATWC says very small tsunami waves were observed along California’s shoreline earlier this morning - http://t.co/co0rfp9CZa",
        id_str: "644567207058477056",
        expectation: (test, callback) ->
            query = new Parse.Query "Story"
            query.equalTo "title", @text
            query.find().then (stories) ->
                test.equal stories.length, 1
                callback()
    }
]

Reset = (callback) ->
    new Parse.Query("Tweet").find (tweets) ->
        Tweet.destroyAll tweets,
            success: () ->
                new Parse.Query("Story").find (stories) ->
                    Story.destroyAll stories,
                        success: () ->
                            callback()
                    
    
exports.testPipeline = (test) ->
    test.expect Tweets.length
    Reset () ->
        nextTweet = (tweetIndex) ->
            if tweetIndex >= Tweets.length
                console.log("\ndone\n")
                test.done()
                return
            
            tweet = Tweets[tweetIndex]
            console.log("\ntesting", tweetIndex, tweet.text)
            processTweet tweet, () ->
                tweet.expectation test, () ->
                    nextTweet tweetIndex + 1
                    
        nextTweet 0
