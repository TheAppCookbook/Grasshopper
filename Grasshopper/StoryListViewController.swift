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

class StoryListViewController: UICollectionViewController {
    // MARK: Properties
    @IBOutlet var titleImageView: UIImageView!
    
    private var stories: [Story] = []
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = self.titleImageView
        
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
    private func reloadData() {
        let query = Story.query()
        query?.orderByDescending("createdAt")
        
        query?.findObjectsInBackgroundWithBlock({ (objs: [AnyObject]?, err: NSError?) in
            self.stories = objs as? [Story] ?? []
            self.collectionView?.reloadData()
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
}

extension StoryListViewController: UICollectionViewDataSource {
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stories.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("StoryCell",
            forIndexPath: indexPath) as! UICollectionViewCell
        let story = self.stories[indexPath.row]
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.setImageWithURL(NSURL(string: story.imageURLString)!)
        
        let titleLabel = cell.viewWithTag(2) as! UILabel
        titleLabel.text = story.title
        
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
            
        // Even, > 3
        case _ where (self.stories.count % 2) == 0:
            switch indexPath.row {
            case 0...1:
                size.width = self.view.frame.width
                
            default:
                let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
                size.width = size.height - (flowLayout.minimumInteritemSpacing / 2.0)
            }
            
        // Odd, > 3
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

extension StoryListViewController: UICollectionViewDelegate {
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let story = self.stories[indexPath.row]
        self.performSegueWithIdentifier("PushStory", sender: story)
    }
}