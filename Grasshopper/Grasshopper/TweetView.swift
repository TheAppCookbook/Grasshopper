//
//  TweetView.swift
//  Grasshopper
//
//  Created by PATRICK PERINI on 8/25/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

class TweetView: UIWebView {
    // MARK: Constants
    private static let embeddedTweetHTML: String = NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("embedded_tweet", ofType: "html")!,
        encoding: NSUTF8StringEncoding,
        error: nil) as! String
    
    // MARK: Properties
    var tweet: Tweet? {
        didSet {
            if let tweet = self.tweet {
                let htmlString = TweetView.embeddedTweetHTML.stringByReplacingOccurrencesOfString("$TWEET_ID",
                    withString: tweet.tweetID,
                    options: nil,
                    range: nil)
                
                self.loadHTMLString(htmlString, baseURL: nil)
            }
        }
    }
    
    var contentHeight: CGFloat {
        let output = self.stringByEvaluatingJavaScriptFromString("Height('container');") as NSString!
        return CGFloat(output.doubleValue)
    }

    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let tweet = self.tweet {
            self.tweet = tweet
        }
    }
}
