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

func resizeWithRotation_test(sourceImage: UIImage, rotationImage: UIImage) -> UIImage? {
    let targetWidth: CGFloat = rotationImage.size.width
    let targetHeight: CGFloat = rotationImage.size.height
    
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
    
    if rotationImage.imageOrientation == .Left {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight)
        
    } else if rotationImage.imageOrientation == .Right {
        CGContextRotateCTM (bitmap, radians(-90))
        CGContextTranslateCTM (bitmap, -targetWidth, 0)
        
    } else if (rotationImage.imageOrientation == .Up) {
        // NOTHING
    } else if (rotationImage.imageOrientation == .Down) {
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

// MARK: - Processing

func combineMaskImages(maskImage1: UIImage, maskImage2: UIImage) -> UIImage? {
    let inputCGImage1    = maskImage1.CGImage
    let inputCGImage2    = maskImage2.CGImage
    let colorSpace       = CGColorSpaceCreateDeviceRGB()
    let width            = CGImageGetWidth(inputCGImage1)
    let height           = CGImageGetHeight(inputCGImage1)
    let bytesPerPixel    = 4
    let bitsPerComponent = 8
    let bytesPerRow      = bytesPerPixel * width
    let bitmapInfo       = RGBA32.bitmapInfo
    
    guard let context1 = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo) else {
        print("unable to create context")
        return nil
    }
    
    guard let context2 = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo) else {
        print("unable to create context")
        return nil
    }
    
    CGContextDrawImage(context1, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), inputCGImage1)
    CGContextDrawImage(context2, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), inputCGImage2)
    
    let pixelBuffer1 = UnsafeMutablePointer<RGBA32>(CGBitmapContextGetData(context1))
    let pixelBuffer2 = UnsafeMutablePointer<RGBA32>(CGBitmapContextGetData(context2))
    
    var currentPixel1 = pixelBuffer1
    var currentPixel2 = pixelBuffer2
    
    let black = RGBA32(red: 0, green: 0, blue: 0, alpha: 255)
    let clear = RGBA32(red: 0, green: 0, blue: 0, alpha: 0)
    
    print("a: \(currentPixel1)")
    print("b: \(currentPixel2)")
    
    for _ in 0 ..< Int(height) {
        for _ in 0 ..< Int(width) {
            
//            if currentPixel1.memory == black {
//                currentPixel1.memory = black
//            }else if currentPixel1.memory == clear {
//                currentPixel1.memory = currentPixel2.memory
//            }else {
//                currentPixel1.memory = clear
//            }
            
//            print("test74219843:: |\(currentPixel2.memory.red)")
            if currentPixel2.memory.red < 100 {
                currentPixel1.memory = black
            }else {
//                currentPixel1.memory = clear
            }
            currentPixel1 += 1
            currentPixel2 += 1
        }
    }
    
    let outputCGImage = CGBitmapContextCreateImage(context1)
    let outputImage = UIImage(CGImage: outputCGImage!, scale: maskImage1.scale, orientation: maskImage1.imageOrientation)
    
    return outputImage
}

func processPixelsInImage(inputImage: UIImage) -> UIImage? {
    let inputCGImage     = inputImage.CGImage
    let colorSpace       = CGColorSpaceCreateDeviceRGB()
    let width            = CGImageGetWidth(inputCGImage)
    let height           = CGImageGetHeight(inputCGImage)
    let bytesPerPixel    = 4
    let bitsPerComponent = 8
    let bytesPerRow      = bytesPerPixel * width
    let bitmapInfo       = RGBA32.bitmapInfo
    
    guard let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo) else {
        print("unable to create context")
        return nil
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), inputCGImage)
    
    let pixelBuffer = UnsafeMutablePointer<RGBA32>(CGBitmapContextGetData(context))
    
    var currentPixel = pixelBuffer
    
    let black = RGBA32(red: 0, green: 0, blue: 0, alpha: 255)
//    let red = RGBA32(red: 255, green: 0, blue: 0, alpha: 255)
//    let green = RGBA32(red: 0, green: 255, blue: 0, alpha: 255)
//    let white = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    let clear = RGBA32(red: 0, green: 0, blue: 0, alpha: 0)
    
    for _ in 0 ..< Int(height) {
        for _ in 0 ..< Int(width) {
//            if currentPixel.memory == black {
            
//            if currentPixel.memory == red {
            if currentPixel.memory.red < 100 {
                currentPixel.memory = black
            }else {
                currentPixel.memory = clear
            }
            currentPixel += 1
        }
    }
    
    let outputCGImage = CGBitmapContextCreateImage(context)
    let outputImage = UIImage(CGImage: outputCGImage!, scale: inputImage.scale, orientation: inputImage.imageOrientation)
    
    return outputImage
}

struct RGBA32: Equatable {
    var color: UInt32
    
    var red: UInt8 {
        return UInt8((color >> 24) & 255)
    }
    
    var green: UInt8 {
        return UInt8((color >> 16) & 255)
    }
    
    var blue: UInt8 {
        return UInt8((color >> 8) & 255)
    }
    
    var alpha: UInt8 {
        return UInt8((color >> 0) & 255)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
    }
    
    static let bitmapInfo = CGImageAlphaInfo.PremultipliedLast.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue
}

func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
    return lhs.color == rhs.color
}
