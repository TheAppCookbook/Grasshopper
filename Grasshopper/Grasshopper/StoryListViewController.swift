//
//  StoryListViewController.swift
//  Grasshopper
//
//  Created by PATRICK PERINI on 8/25/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit
import AFNetworking
import ACBInfoPanel
import Parse

class StoryListViewController: UICollectionViewController {
    // MARK: Properties
    @IBOutlet var titleImageView: UIImageView!
    private var stories: [Story] = []
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = self.titleImageView

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = self.navigationController?.navigationBar.barTintColor
        refreshControl.addTarget(self,
            action: "refreshControlWasTriggered:",
            forControlEvents: .ValueChanged)
        
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.addSubview(refreshControl)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case .Some("PushStory"):
            let story = sender as! Story
            let storyVC = segue.destinationViewController as! StoryViewController
            storyVC.story = story
        
        default:
            break
        }
    }
    
    // MARK: Data Handlers
    private func reloadData(completion: (() -> Void)={}) {
        let query = Story.query()
        query?.orderByDescending("createdAt")
        
        query?.findObjectsInBackgroundWithBlock({ (objs: [PFObject]?, err: NSError?) in
            self.stories = objs as? [Story] ?? []
            self.collectionView?.reloadData()
            completion()
        })
    }
    
    // MARK: Responders
    @IBAction func titleViewWasTapped(sender: UITapGestureRecognizer!) {
        let infoPanel = ACBInfoPanelViewController()
        infoPanel.ingredient = "@GrasswireNow"
        
        self.presentViewController(infoPanel,
            animated: true,
            completion: nil)
    }
    
    func refreshControlWasTriggered(sender: UIRefreshControl!) {
        self.reloadData {
            sender.endRefreshing()
        }
    }
}

extension StoryListViewController { // UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stories.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("StoryCell",
            forIndexPath: indexPath) as UICollectionViewCell
        let story = self.stories[indexPath.row]
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = nil
        imageView.setImageWithURL(story.imageURL!)
        
        let titleLabel = cell.viewWithTag(2) as! UILabel
        titleLabel.text = story.title
        
        let tweetCountLabel = cell.viewWithTag(3) as! UILabel
        tweetCountLabel.text = "..."
        story.tweets.query()?.countObjectsInBackgroundWithBlock({ (count: Int32, err: NSError?) in
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .DecimalStyle
            tweetCountLabel.text = numberFormatter.stringFromNumber(NSNumber(int: count))
        })
        
        return cell
    }
}

extension StoryListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = CGSize(width: 0, height: self.view.frame.width / 2.0)
        
        switch self.stories.count {
        // Up to 3
        case 1...3:
            size.width = self.view.frame.width
            size.height = self.view.frame.height / CGFloat(self.stories.count)
            
        // 4 exactly
        case 4:
            switch indexPath.row {
            case 0...1:
                size.width = self.view.frame.width
                
            default:
                let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
                size.width = size.height - (flowLayout.minimumInteritemSpacing / 2.0)
            }
            
            size.height = self.view.frame.size.height / 3.0
            
        // Even, > 4
        case _ where (self.stories.count % 2) == 0:
            switch indexPath.row {
            case 0...1:
                size.width = self.view.frame.width
                
            default:
                let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
                size.width = size.height - (flowLayout.minimumInteritemSpacing / 2.0)
            }
            
        // Odd, > 4
        default:
            switch indexPath.row {
            case 0...2:
                size.width = self.view.frame.width
                
            default:
                let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
                size.width = size.height - (flowLayout.minimumInteritemSpacing / 2.0)
            }
        }
        
        return size
    }
}

extension StoryListViewController { // UICollectionViewControllerDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let story = self.stories[indexPath.row]
        self.performSegueWithIdentifier("PushStory", sender: story)
    }
}