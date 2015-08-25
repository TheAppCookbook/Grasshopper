//
//  GrayscaleImageView.swift
//  Grasshopper
//
//  Created by PATRICK PERINI on 8/25/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

class GrayscaleImageView: UIImageView {
    // MARK: Properties
    private var internalSetImage: UIImage?
    
    override var image: UIImage? {
        didSet {
            if let image = self.image {
                if image != self.internalSetImage {
                    self.internalSetImage = image.imageWithGrayscale()
                    self.image = self.internalSetImage
                    self.internalSetImage = nil
                }
            }
        }
    }
}
