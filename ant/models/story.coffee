# Imports
Parse = require("parse").Parse
ImageSearch = require("google-images")


Story = Parse.Object.extend "Story", {
    # Accessors
    tweets: (callback) ->
        require("./tweet")
        query = @relation("tweets").query()
        query.descending "createdAt"
        
        query.find
            success: (tweets) ->
                callback(tweets)
            error: (error) ->
                callback(null)
                
    fallbackImageURL: (callback) ->
        @tweets (tweets) ->
            latestTweet = tweets[0]
            unless latestTweet?
                callback(null)
                return
            
            search = (keywordCount) ->
                if keywordCount == 0
                    callback(null)
                    return
            
                query = latestTweet.keywords().slice(0, keywordCount).join(",")
                ImageSearch.search query, (err, photos) ->
                    unless photos.length > 0
                        search(keywordCount - 1)
                        return
            
                    photo = photos[0]
                    callback(photo.url)
                    
            search(Math.min(latestTweet.keywords().length, 3))

    # Mutators
    addTweet: (tweet, callback) ->
        # callback(addedTweet, alreadyAdded)
        
        if tweet.get("isBreaking")
            callback(null, false)
            return
                    
        self = this
        @tweets (tweets) ->
            latestTweet = tweets[0]
            
            # prune duplicates
            dupeQuery = new Parse.Query "Tweet"
            dupeQuery.equalTo "text", tweet.get("text")
            dupeQuery.first
                success: (dupeTweet) ->
                    console.log("searching for dupe", tweet.get("text"), "found", dupeTweet?.get("tweetID"))
                    if dupeTweet?
                        callback(null, true)
                        return
                
                    # find time chunk
                    latestTime = latestTweet.createdAt.getTime()
                    elapsedTime = (new Date).getTime() - latestTime
                    sameTimeChunk = elapsedTime < Story.lapseTime
                    
                    unless sameTimeChunk
                        callback(null, false)
                        return
                        
                    # compare texts
                    isApproximate = false
                    for oldTweet in tweets
                        if oldTweet.proximityToTweet(tweet) > 0
                            isApproximate = true
                            break
                    
                    unless isApproximate
                        callback(null, false)
                        return
                    
                    # add it
                    if (not self.get("imageURLString")?) and tweet.get("mediaURL")?
                        self.set "imageURLString", tweet.get("mediaURL")
                        
                    tweet.save null,
                        success: (newTweet) ->
                            self.relation("tweets").add newTweet
                            callback(tweet, false)
                            
                        error: () ->
                            callback(null, false)
                    
    saveWithInitialTweet: (tweet, callback) ->
        self = this
        
        @save null,
        success: () ->
            tweet.save null,
                success: () ->
                    self.relation("tweets").add tweet
                    self.save null,
                        success: () ->
                            if callback?
                                callback()
}, {
    # Class Properties
    lapseTime: 10800000  # 3 hours in milliseconds
    
    # Initializers
    fromTweetData: (tweetData) ->
        text = tweetData.text
        mediaURL = tweetData.entities?.media?[0]?.media_url or null
        
        story = new Story
        story.set "title", text
        story.set "imageURLString", mediaURL
        
        Story._mostRecent = null
        return story
        
    # Class Accessors
    _mostRecent: null
    mostRecent: (callback) ->
        if Story._mostRecent?
            callback(Story._mostRecent)
            return
            
        query = new Parse.Query Story
        query.descending "createdAt"
        query.first
            success: (story) ->
                Story._mostRecent = story
                callback(story)
            error: () ->
                callback(null)
        
    forTweet: (tweet, callback) ->
        query = new Parse.Query Story
        query.equalTo "tweets", tweet
        query.first
            success: (story) ->
                callback(story)
            error: () ->
                callback(null)
}

module.exports = Story
