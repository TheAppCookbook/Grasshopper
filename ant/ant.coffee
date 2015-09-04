# Imports
#throng = require "throng"
Parse = require("parse").Parse
Tweet = require "./models/tweet"
Story = require "./models/story"
throng = require "throng"


# Setup
Parse.initialize "MAJ7aKEx6PNiDxONOIzwSP29QEeZ3i9dkz5tkj2o",
    "SFrizfmgICHbDha7OsJD30GLxACYUYkBWa9omGBO"

# Main
start = () ->
    streamOptions =
        follow: '747682134,3281311297'
        
    try
        console.log("starting stream...")
        Tweet.stream streamOptions, (tweetData) ->
            processTweet(tweetData)
    catch error
        console.log("streaming error:", error)
    
throng start,
    workers: 1
    lifetime: Infinity
    
# Handlers
processTweet = (tweetData) -> 
    # console.log(tweetData)
    
    # delete
    if tweetData.delete?
        idString = tweetData.delete.status.id_str
        Tweet.find {"tweetID": idString}, (tweets) ->
            tweet = tweets[0]
            unless tweet?
                return
                
            tweet.destroyWithCascade()

        return
    
    # new tweet (assumed)
    Story.mostRecent (story) ->
        unless story?
            story = Story.fromTweetData tweetData
            tweet = Tweet.fromTweetData tweetData
            
            story.saveWithInitialTweet tweet
            console.log("creating first story from tweet", tweet.get("tweetID"))
            return
            
        console.log("most recent story", story.get("title"))
        
        tweet = Tweet.fromTweetData tweetData
        story.addTweet tweet, (addedTweet, alreadyAdded) ->
            if addedTweet?
                console.log("adding tweet", tweet.get("tweetID") , "to most recent story")
                story.save()
                return
            else if alreadyAdded
                console.log("skipping duplicate tweet", tweet.get("tweetID"))
                return
            
            console.log("creating story from tweet", tweet.get("tweetID"))
            
            newStory = Story.fromTweetData tweetData
            newStory.saveWithInitialTweet tweet
            