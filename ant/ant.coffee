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
        console.log("streaming error: ", error)
    
throng start,
    workers: 1
    lifetime: Infinity
    
# Handlers
processTweet = (tweetData) ->
    idString = tweetData.attributes.id_str
    text = tweetData.attributes.text
    
    entities = JSON.parse(tweetData._hashedJSON?.entities)
    media_url = entities?.media?[0]?.media_url or null
    
    Story.mostRecent (story) ->
        unless story?
            console.log("creating story from tweet ", idString)
            
            story = new Story
            story.set("title", text)
            story.set("imageURLString", media_url)
            story.save()
            
            return
        
        story.allTweets (tweets) ->
            latestTweet = tweets[0]
            elapsedTime = (new Date).getTime() - (latestTweet?.createdAt.getTime() or 0)
            sameDay = elapsedTime < 43200000  # milliseconds in 12 hours
            
            if sameDay
                console.log("adding tweet ", idString, " to most recent story")
                
                tweet = new Tweet
                tweet.set("tweetID", idString)
                tweet.save () ->
                    story.tweets().add(tweet)
                    
                    if not story.get("imageURLString")? and media_url?
                        story.set("imageURLString", media_url)
                    
                    story.save()
            else
                console.log("creating story from tweet ", idString)
            
                story = new Story
                story.set("title", text)
                story.set("imageURLString", media_url)
                story.save()
            