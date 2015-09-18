# Imports
Twitter = require("twitter")
Parse = require("parse").Parse
Story = require("./story")
POS = require("pos")
HTMLEntities = require("html-entities").AllHtmlEntities


Tweet = Parse.Object.extend "Tweet", {
    # Accessors
    keywords: () ->
        # https://github.com/dariusk/pos-js
        partsOfSpeech = [
            "NNPS", "NNP", "FW", "JJ",
            "NN", "NNS", "UH",
            "VBG", "VB", "VBD", "VBN",
            "VBP", "VBZ"
        ]
        
        filteredTerms = [
            "http", "https"
        ]
        
        taggedWords = Tweet._tagger.tag(Tweet._lexer.lex(@get("text")))
        longEnoughWords = taggedWords.filter ($0) ->
            return $0[0].length > 3
        
        keywords = longEnoughWords.filter ($0) ->
            # filter out trivial parts of speech
            return partsOfSpeech.indexOf($0[1]) != -1
        
        keywords = keywords.sort ($0, $1) ->
            # filter twitter semantics
            if $0[0].indexOf("@") == 0 or $0[0].indexOf("#") == 0
                return 1
            
            # sort by part of speech
            return partsOfSpeech.indexOf($0[1]) - partsOfSpeech.indexOf($1[1])
            
        keywords = keywords.map ($0) ->
            # lowercase for standardization
            return $0[0].toLowerCase()
            
        keywords = keywords.filter ($0) ->
            return filteredTerms.indexOf($0) == -1
            
        return keywords
            
    proximityToTweet: (anotherTweet) ->
        thisKeywords = @keywords()
        otherKeywords = anotherTweet.keywords()
        
        matches = thisKeywords.filter ($0) ->
            otherKeywords.indexOf($0) != -1
        
        console.log(@get('text'), "is approx to", anotherTweet.get('text'), "by", matches.length, matches)
        return matches.length
    
    # Mutators
    destroyWithCascade: (callback) ->
        self = this
        
        Story.forTweet this, (story) ->
            story.tweets (tweets) ->
                destroyStory = tweets.indexOf(self) == 0
                
                console.log("destroying tweet", self.get("tweetID"))
                self.destroy
                
                if destroyStory
                    story.destroy().then () ->
                        callback?()
                    
                    console.log("destroying story", story.get("title"))
                else
                    callback?()
}, {
    # Class Properties
    _client: new Twitter
        consumer_key: "AuIeip7tJbQec6W1jp5EEaGaL"
        consumer_secret: "QM7O2qHuI08YT5heU6wJc0rkxCZNpvqxRGWIrVR0cIyHbhvyDP"
        access_token_key: "10125612-qTock7QLLQjhc2UdlIVIRoGPBAN1fTAHZaVhdFMfU"
        access_token_secret: "EPWE4lhyTjzBqjkk9oVe92QMirvlz0pygQudg7wNzrVp9"
        
    _lexer: new POS.Lexer
    _tagger: new POS.Tagger
    _htmlEncoder: new HTMLEntities
    
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
        tweet.set "isBreaking", tweetData.text.indexOf("BREAKING") != -1
        tweet.set "mediaURL", tweetData.entities?.media?[0]?.media_url or null
        tweet.set "text", Tweet._htmlEncoder.decode(tweetData.text)
        
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
        query.find().then (tweets) ->
            callback(tweets)
}
        
module.exports = Tweet
