//
//  StoryViewController.swift
//  Grasshopper
//
//  Created by PATRICK PERINI on 8/25/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

class StoryViewController: UITableViewController {
    // MARK: Properties
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var headerTitelLabel: UILabel!
    @IBOutlet var titleImageView: UIImageView!
    @IBOutlet var shareButtonItem: UIBarButtonItem!
    
    private var tweets: [Tweet] = []
    var story: Story?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = self.titleImageView
        self.navigationItem.rightBarButtonItem = self.shareButtonItem
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 350.0
        
        self.reloadData()
    }
    
    // MARK: Data Handlers
    private func reloadData() {
        self.headerImageView.setImageWithURL(NSURL(string: self.story!.imageURLString)!)
        self.headerTitelLabel.text = self.story!.title
        
        let query = self.story?.tweets.query()
        query?.orderByDescending("createdAt")
        
        query?.findObjectsInBackgroundWithBlock({ (objs: [AnyObject]?, err: NSError?) in
            self.tweets = objs as? [Tweet] ?? []
            self.tableView.reloadData()
        })
    }
    
    // MARK: Responders
    @IBAction func shareButtonWasPressed(sender: UIBarButtonItem!) {
        
    }
}

extension StoryViewController: UITableViewDataSource {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! UITableViewCell
        let tweet = self.tweets[indexPath.row]
        
        let tweetView = cell.viewWithTag(1) as! TweetView
        tweetView.tweet = tweet
        tweetView.delegate = self
        
        if let constraint = tweetView.constraints().first as? NSLayoutConstraint {
            constraint.constant = self.tableView.estimatedRowHeight
        }
        
        return cell
    }
}

extension StoryViewController: UITableViewDelegate {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweet = self.tweets[indexPath.row]
        var url = NSURL(string: "twitter://status?id=\(tweet.tweetID)")!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            url = NSURL(string: "https://twitter.com/GrasswireNow/status/\(tweet.tweetID)")!
            UIApplication.sharedApplication().openURL(url)
        }
    }
}

extension StoryViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let visible = CGRectGetMaxY(webView.frame) > 0
        if !visible {
            return false
        }
        
        if let requestURL = request.URL?.absoluteString {
            if requestURL.hasPrefix("grasshopper:ready") {
                let height = (webView as! TweetView).contentHeight + 10.0
                
                if let constraint = webView.constraints().first as? NSLayoutConstraint {
                    if constraint.constant != height {
                        self.tableView.beginUpdates()
                        constraint.constant = height
                        self.tableView.endUpdates()
                    }
                }
                
                return false
            }
        }
        
        return true
    }
}
