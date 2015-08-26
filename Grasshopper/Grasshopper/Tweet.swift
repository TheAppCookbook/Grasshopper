//
//  Tweet.swift
//  Grasshopper
//
//  Created by PATRICK PERINI on 8/25/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import Parse

class Tweet: PFObject, PFSubclassing {
    // MARK: Properties
    @NSManaged var tweetID: String
    
    static func parseClassName() -> String {
        return "Tweet"
    }
}
