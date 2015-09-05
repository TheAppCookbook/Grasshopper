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
        let imageRect = CGRectMake(0,0,CGFloat(CGImageGetWidth(self.CGImage)),CGFloat(CGImageGetHeight(self.CGImage)))
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGBitmapContextCreate(nil,
            CGImageGetWidth(self.CGImage),
            CGImageGetHeight(self.CGImage),
            8, 0, colorSpace,
            CGBitmapInfo.ByteOrderDefault.rawValue)
        CGContextDrawImage(context, imageRect, self.CGImage)
        
        let imageRef = CGBitmapContextCreateImage(context)
        
        let newImage = UIImage(CGImage: imageRef!, scale: CGFloat(CGImageGetWidth(self.CGImage))/self.size.width, orientation: UIImageOrientation.Up)
        return newImage
    }
}
