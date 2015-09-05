//
//  StoryViewController.swift
//  Grasshopper
//
//  Created by PATRICK PERINI on 8/25/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {
    // MARK: Properties
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var headerTitelLabel: UILabel!
    @IBOutlet var titleImageView: UIImageView!
    @IBOutlet var tweetContainerView: TweetContainerView!
    
    private var tweets: [Tweet] = []
    var story: Story?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = self.titleImageView
        
        self.reloadData()
    }
    
    // MARK: Data Handlers
    private func reloadData() {
        self.headerImageView.setImageWithURL(self.story!.imageURL!)
        
        self.headerTitelLabel.text = self.story!.title
        self.headerTitelLabel.superview?.bringSubviewToFront(self.headerTitelLabel)
        
        let query = self.story?.tweets.query()
        query?.orderByDescending("createdAt")
        
        query?.findObjectsInBackgroundWithBlock({ (objs: [AnyObject]?, err: NSError?) in
            self.tweets = objs as? [Tweet] ?? []
            
            self.tweetContainerView.tweets = self.tweets
            self.tweetContainerView.reloadData()
        })
    }
}

extension StoryViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let visible = CGRectGetMaxY(webView.frame) > 0
        if !visible {
            return false
        }
        
        if let requestURL = request.URL?.absoluteString {
            print("REQ: \(requestURL), NAV: \(navigationType.rawValue)")
            
            if requestURL.hasPrefix("http") && navigationType == .LinkClicked {
                UIApplication.sharedApplication().openURL(request.URL!)
                return false
            }
        }
        
        return true
    }
}
