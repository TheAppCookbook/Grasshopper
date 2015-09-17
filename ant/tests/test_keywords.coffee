Tweet = require "../models/tweet"


firstTweet = Tweet.fromTweetData
	id_str: "0"
	text: "Hungarian riot police push refugees back onto train that's been at standstill in Bicske, Hungary. Police seem to be sealing train: CNN team"
	
relatedTweet = Tweet.fromTweetData
	id_str: "1"
	text: "Riot police now heading towards #Bicske train, with refugees onboard. http://t.co/PK5OfstyTp"
	
unrelatedTweet = Tweet.fromTweetData
	id_str: "2"
	text: "Fridays are usually slow news days. Today is not one of those days. Join us in the world's biggest open newsroom - http://t.co/FFb1rbgzqh"
	

exports.testKeywords = (test) ->
	test.deepEqual firstTweet.keywords(), [ 'police',
		'hungary',
		'standstill',
		'hungarian',
		'team',
		'train',
		'riot',
		'bicske',
		'train',
		'police',
		'refugees',
		'sealing',
		'seem',
		'push',
		'been'
	]
	
	test.done()
	
exports.testProximity = (test) ->
	test.ok firstTweet.proximityToTweet(relatedTweet) > 0
	test.ok firstTweet.proximityToTweet(unrelatedTweet) == 0
	test.done()