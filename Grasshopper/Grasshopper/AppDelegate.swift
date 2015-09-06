//
//  AppDelegate.swift
//  Grasshopper
//
//  Created by PATRICK PERINI on 8/25/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Setup Parse
        Parse.setApplicationId("MAJ7aKEx6PNiDxONOIzwSP29QEeZ3i9dkz5tkj2o",
            clientKey: "zefcVYTBph7fm9JQ42A3HhaAXAhFAyvduGWmv1c8")
        
        Story.registerSubclass()
        Tweet.registerSubclass()
        
//        Story.generatePlaceholders()
        
        // Setup Appearance
        application.statusBarStyle = .LightContent
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "OpenSans-Semibold", size: 15.0)!
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(UINavigationBar.appearance().titleTextAttributes,
            forState: UIControlState.Normal)
        
        return true
    }
}

