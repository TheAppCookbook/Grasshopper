//
//  TweetContainerView.swift
//  Grasshopper
//
//  Created by PATRICK PERINI on 8/25/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

class TweetContainerView: UIWebView {
    // MARK: Constants
    private static let embeddedTweetsContainerHTML: String = try! NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("embedded_tweets_container", ofType: "html")!,
        encoding: NSUTF8StringEncoding) as String
    
    private static let embeddedTweetHTML: String = try! NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("embedded_tweet", ofType: "html")!,
        encoding: NSUTF8StringEncoding) as String
    
    // MARK: Properties
    var tweets: [Tweet] = [] {
        didSet {
            self.reloadData()
        }
    }
    
    @IBOutlet var scrollViewDelegate: UIScrollViewDelegate? {
        didSet {
            self.scrollView.delegate = self.scrollViewDelegate
        }
    }

    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.reloadData()
    }
    
    // MARK: Data Handlers
    func reloadData() {
        var htmlStrings: [String] = []
        
        for tweet in self.tweets {
            let htmlString = TweetContainerView.embeddedTweetHTML.stringByReplacingOccurrencesOfString("$TWEET_ID",
                withString: tweet.tweetID,
                options: [],
                range: nil)
            htmlStrings.append(htmlString)
        }
        
        let content = htmlStrings.joinWithSeparator("\n")
        let page = TweetContainerView.embeddedTweetsContainerHTML.stringByReplacingOccurrencesOfString("$TWEETS",
            withString: content,
            options: [],
            range: nil)
        
        self.loadHTMLString(page, baseURL: nil)
    }
}
