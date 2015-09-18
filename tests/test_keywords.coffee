# Imports
Tweet = require "../models/tweet"


# Setup
firstTweet = Tweet.fromTweetData
	id_str: "0"
	text: "RT @MatthewKeysLive: American Airlines spokesperson tells me “technical issues” are causing flights to be grounded nationwide."
	
relatedTweet = Tweet.fromTweetData
	id_str: "1"
	text: "RT @grasswire: American Airlines grounds flights in U.S. over “technical glitch,” airliner confirms to Grasswire - http://t.co/2dHMbbit7M"
	
unrelatedTweet = Tweet.fromTweetData
	id_str: "2"
	text: "NWATWC says very small tsunami waves were observed along California’s shoreline earlier this morning - http://t.co/co0rfp9CZa"
	
	
# Tests
exports.testProximity = (test) ->
	test.ok firstTweet.proximityToTweet(relatedTweet) > 0
	test.ok firstTweet.proximityToTweet(unrelatedTweet) == 0
	test.done()