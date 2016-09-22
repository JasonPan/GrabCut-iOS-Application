//
//  ImageProcessingHelpers.swift
//  GrabCutIOS
//
//  Created by Jason @ Monash on 22/09/2016.
//  Copyright © 2016 EunchulJeon. All rights reserved.
//

import UIKit

func radians(degrees: Double) -> Double { return degrees * M_PI/180 }
func radians(degrees: Int) -> Int { return Int(radians(Double(degrees))) }
func radians(degrees: CGFloat) -> CGFloat { return CGFloat(radians(Double(degrees))) }
let MAX_IMAGE_LENGTH: CGFloat = 450

func resizeImage(image: UIImage, size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)
    let context: CGContextRef? = UIGraphicsGetCurrentContext()
    CGContextTranslateCTM(context, 0.0, size.height)
    CGContextScaleCTM(context, 1.0, -1.0)
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height), image.CGImage)
    let scaledImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
}

func resizeWithRotation(sourceImage: UIImage, size targetSize: CGSize) -> UIImage? {
    let targetWidth: CGFloat = targetSize.width
    let targetHeight: CGFloat = targetSize.height
    
    let imageRef: CGImageRef? = sourceImage.CGImage
    var bitmapInfo: CGBitmapInfo = CGImageGetBitmapInfo(imageRef)
    let colorSpaceInfo: CGColorSpaceRef? = CGImageGetColorSpace(imageRef)
    
    if bitmapInfo == CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue) {
        bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipFirst.rawValue)
    }
    
    var bitmap: CGContextRef?
    
    if sourceImage.imageOrientation == .Up || sourceImage.imageOrientation == .Down {
        bitmap = CGBitmapContextCreate(nil, Int(targetWidth), Int(targetHeight), CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo.rawValue)
        
    } else {
        bitmap = CGBitmapContextCreate(nil, Int(targetHeight), Int(targetWidth), CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo.rawValue)
        
    }
    
    if sourceImage.imageOrientation == .Left {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight)
        
    } else if sourceImage.imageOrientation == .Right {
        CGContextRotateCTM (bitmap, radians(-90))
        CGContextTranslateCTM (bitmap, -targetWidth, 0)
        
    } else if (sourceImage.imageOrientation == .Up) {
        // NOTHING
    } else if (sourceImage.imageOrientation == .Down) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    if let ref: CGImageRef = CGBitmapContextCreateImage(bitmap) {
        let newImage = UIImage(CGImage: ref)
        return newImage;
    }
    
    return nil
}

func masking(sourceImage: UIImage, mask maskImage: UIImage) -> UIImage? {
    //Mask Image
    let maskRef: CGImageRef? = maskImage.CGImage
    
    let mask: CGImageRef? = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                              CGImageGetHeight(maskRef),
                                              CGImageGetBitsPerComponent(maskRef),
                                              CGImageGetBitsPerPixel(maskRef),
                                              CGImageGetBytesPerRow(maskRef),
                                              CGImageGetDataProvider(maskRef), nil, false);
    
    if let masked: CGImageRef = CGImageCreateWithMask(sourceImage.CGImage, mask) {
        let maskedImage: UIImage = UIImage(CGImage: masked)
        return maskedImage;
    }
    
    return nil
}

func getResizeForTimeReduce(image: UIImage) -> CGSize {
    let ratio: CGFloat = image.size.width / image.size.height
    
    if image.size.width > image.size.height {
        if image.size.width > 400 {
            return CGSizeMake(400, 400/ratio)
        }else {
            return image.size
        }
        
    }else{
        if image.size.height > 400 {
            return CGSizeMake(ratio/400, 400)
        }else {
            return image.size
        }
    }
}
