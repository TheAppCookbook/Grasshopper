//
//  Story.swift
//  Grasshopper
//
//  Created by PATRICK PERINI on 8/25/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import Parse

class Story: PFObject, PFSubclassing {
    // MARK: Properties
    @NSManaged var title: String
    @NSManaged var imageURLString: String
    @NSManaged private(set) var tweets: PFRelation
    
    var imageURL: NSURL? {
        let urlString = (self.valueForKey("imageURLString") as? String) ?? ""
        return NSURL(string: urlString)
    }
    
    static func parseClassName() -> String {
        return "Story"
    }
    
    // MARK: Generators
    class func generatePlaceholders() {
        // Black Monday
        let blackMonday: () -> Void = {
            let newStory = Story()
            newStory.title = "Dow bounces back slightly after 1,000-point drop at market open - http://bit.ly/1PuIVpI  #BlackMonday"
            newStory.imageURLString = "https://pbs.twimg.com/media/CNLn4AMWIAAYGBT.jpg:large"
            try! newStory.save()
            
            let tweets = [
                "635825879705341952",
                "635826458619985922",
                "635825900081143808",
                "635824801135894528",
                "635821492912189441",
                "635824494142226432",
                "635824712267005952",
                "635812329519738880"
            ]
            
            for tweetID in tweets {
                let tweet = Tweet()
                tweet.tweetID = tweetID
                try! tweet.save()
                
                newStory.tweets.addObject(tweet)
            }
            
            try! newStory.save()
        }
        
        // Ferguson
        let ferguson: () -> Void = {
            let newStory = Story()
            newStory.title = "Video: Gunshots heard at protest in #Ferguson, Missouri (video: @search4swag) - grasswire.com/ferguson pic.twitter.com/rwQfInYRhP"
            newStory.imageURLString = "https://pbs.twimg.com/media/CMBcnybWUAADfdD.jpg:large"
            try! newStory.save()
            
            let tweets = [
                "630609081615679488",
                "630610202576850944",
                "630605803133771776",
                "630604114888527872",
                "630604570574491649",
                "630604055044173824"
            ]
            
            for tweetID in tweets {
                let tweet = Tweet()
                tweet.tweetID = tweetID
                try! tweet.save()
                
                newStory.tweets.addObject(tweet)
            }
            
            try! newStory.save()
        }
        
        // Explosion
        let explosion: () -> Void = {
            let newStory = Story()
            newStory.title = "More: Motel 6 Bremerton, WA exploded fifteen minutes after being evacuated due to a gas leak - @seattletimes http://t.co/5JshGtxzYT"
            newStory.imageURLString = "https://pbs.twimg.com/media/CMvocX4UAAAYw-e.jpg:large"
            try! newStory.save()
            
            let tweets = [
                "633859044524949504",
                "633858758360199169",
                "633859267779428352",
                "633858146734223360"
            ]
            
            for tweetID in tweets {
                let tweet = Tweet()
                tweet.tweetID = tweetID
                try! tweet.save()
                
                newStory.tweets.addObject(tweet)
            }
            
            try! newStory.save()
        }
        
        ferguson()
        explosion()
        blackMonday()
    }
}
