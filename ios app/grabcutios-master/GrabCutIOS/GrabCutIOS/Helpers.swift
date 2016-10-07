//
//  Helpers.swift
//  FIT1041 GrabCut
//
//  Created by Jason @ Monash on 6/10/2016.
//  Copyright © 2016 EunchulJeon. All rights reserved.
//

import Foundation

let shouldSaveResults: Bool = false
var inAutoMode: Bool = true

let shouldIsolateGreen: Bool = false










func getDocumentsDirectory() -> NSURL {
    let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

// based on https://gist.github.com/samuel-mellert/20b3c99dec168255a046
// which is based on https://gist.github.com/szhernovoy/276e69eb90a0de84dd90
// Updated to work on Swift 2.2

func randomString(length: Int) -> String {
    let charactersString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let charactersArray : [Character] = Array(charactersString.characters)
    
    var string = ""
    for _ in 0..<length {
        string.append(charactersArray[Int(arc4random()) % charactersArray.count])
    }
    
    return string
}

// See: http://stackoverflow.com/a/37955552/699963
extension UIImage {
    
    func imageWithAlpha(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        drawAtPoint(CGPointZero, blendMode: .Normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}

// See: http://stackoverflow.com/a/34410888/699963
//func TransperentImageToWhite(image: UIImage) -> UIImage {
func colourisedImageWithImage(image: UIImage, colour: UIColor) -> UIImage {
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let imageRect: CGRect = CGRectMake(0.0, 0.0, image.size.width, image.size.height)
    let ctx: CGContextRef? = UIGraphicsGetCurrentContext()
    // Draw a white background (for white mask)
//    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0)
    CGContextSetRGBFillColor(ctx, colour.red, colour.green, colour.blue, colour.alpha)
    CGContextFillRect(ctx, imageRect)
    // Apply the source image's alpha
    image.drawInRect(imageRect, blendMode: .Normal, alpha: 1.0)
    let mask: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return mask
}

// See: http://stackoverflow.com/a/34890134/699963
extension UIColor{
    
    var red: CGFloat{
        return CGColorGetComponents(self.CGColor)[0]
    }
    
    var green: CGFloat{
        return CGColorGetComponents(self.CGColor)[1]
    }
    
    var blue: CGFloat{
        return CGColorGetComponents(self.CGColor)[2]
    }
    
    var alpha: CGFloat{
        return CGColorGetComponents(self.CGColor)[3]
    }
}
