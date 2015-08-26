//
//  UIImage+Filters.swift
//  Grasshopper
//
//  Created by PATRICK PERINI on 8/25/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

extension UIImage {
    func imageWithGrayscale() -> UIImage {
        var imageRect = CGRectMake(0,0,CGFloat(CGImageGetWidth(self.CGImage)),CGFloat(CGImageGetHeight(self.CGImage)))
        
        var colorSpace = CGColorSpaceCreateDeviceGray()
        var context = CGBitmapContextCreate(nil, CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage), 8, 0, colorSpace, CGBitmapInfo.ByteOrderDefault)
        CGContextDrawImage(context, imageRect, self.CGImage)
        
        var imageRef = CGBitmapContextCreateImage(context)
        
        var newImage = UIImage(CGImage: imageRef!, scale: CGFloat(CGImageGetWidth(self.CGImage))/self.size.width, orientation: UIImageOrientation.Up)
        
        return newImage!
    }
}
