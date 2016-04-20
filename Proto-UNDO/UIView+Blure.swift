//
//  UIView+Blure.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 13.08.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit
extension UIView {
    func getBlur() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 1);
        // 3
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        // 4
        let screenshot:UIImage  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        let fname = "CIGaussianBlur";
        let context:CIContext = CIContext(options: nil)
        let image:CIImage = CIImage (CGImage: screenshot.CGImage!)
        let filter:CIFilter = CIFilter(name: fname)!
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(10 as NSNumber, forKey: kCIInputRadiusKey)
        
        let result:CIImage  = filter.valueForKey(kCIOutputImageKey) as! CIImage
        let extent:CGRect = result.extent
        let cgImage:CGImageRef = context.createCGImage(result, fromRect: extent)
        let img:UIImage = UIImage(CGImage: cgImage, scale: screenshot.scale, orientation: screenshot.imageOrientation)
        return img;
    }
}