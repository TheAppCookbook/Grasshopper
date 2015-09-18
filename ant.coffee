# Imports
Parse = require("parse").Parse
Tweet = require("./models/tweet")
Story = require("./models/story")
throng = require("throng")


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
    
if require.main == module
    # Setup
    Parse.initialize "MAJ7aKEx6PNiDxONOIzwSP29QEeZ3i9dkz5tkj2o",
        "SFrizfmgICHbDha7OsJD30GLxACYUYkBWa9omGBO"
    
    throng start,
        workers: 1
        lifetime: Infinity
    
# Handlers
processTweet = (tweetData, findImages = true, callback) ->
    # delete
    if tweetData.delete?
        idString = tweetData.delete.status.id_str
        Tweet.find {"tweetID": idString}, (tweets) ->
            tweet = tweets[0]
            unless tweet?
                callback?()
                return
                
            tweet.destroyWithCascade () ->
                callback?()
        return
    
    # new tweet (assumed)
    tweet = Tweet.fromTweetData tweetData
    unless tweet?
        callback?()
        return
    
    Story.mostRecent (story) ->
        unless story?
            story = Story.fromTweetData tweetData

            story.saveWithInitialTweet tweet, () ->
                callback?()
                
            console.log("creating first story from tweet", tweet.get("tweetID"))
            return
            
        console.log("most recent story", story.get("title"))
        story.addTweet tweet, (addedTweet, alreadyAdded) ->
            if addedTweet?
                console.log("adding tweet", tweet.get("tweetID") , "to most recent story")
                story.save().then () ->
                    callback?()
                    
                return
            else if alreadyAdded
                console.log("skipping duplicate tweet", tweet.get("tweetID"))
                callback?()
                return
            
            console.log("creating story from tweet", tweet.get("tweetID"))
            
            if not story.get("imageURLString")? and findImages
                console.log("searching for fallback image for last story")
                story.fallbackImageURL (url) ->
                    story.set "imageURLString", url
                    story.save()
            
            newStory = Story.fromTweetData tweetData
            newStory.saveWithInitialTweet tweet, () ->
                callback?()
                    
module.exports = processTweet
