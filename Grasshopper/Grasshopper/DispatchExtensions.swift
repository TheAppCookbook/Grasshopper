//
//  DispatchExtensions.swift
//  BlueSkies
//
//  Created by PATRICK PERINI on 8/19/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import Foundation

func dispatch_after(time: NSTimeInterval, queue: dispatch_queue_t = dispatch_get_main_queue(), block: dispatch_block_t) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSTimeInterval(NSEC_PER_SEC) * time)),
        queue,
        block)
}