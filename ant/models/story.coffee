# Imports
Parse = require("parse").Parse


Story = Parse.Object.extend "Story",
    tweets: () ->
        return @relation("tweets")
    
    allTweets: (callback) ->
        query = @tweets().query()
        query.descending "createdAt"
        
        query.find {
            success: (tweets) ->
                callback(tweets)
            error: (error) ->
                callback(null)
        }
        

# Class Accessors
_mostRecent = null
Story.mostRecent = (callback) ->
    if _mostRecent?
        callback(_mostRecent)
        return
        
    query = new Parse.Query Story
    query.descending "createdAt"
    query.first {
        success: (story) ->
            callback(story)
        error: (error) ->
            callback(null)
    }

module.exports = Story
