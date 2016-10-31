/*
 Copyright (c) 2016 Jason Pan
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

//
//  Image Utilities.swift
//  FIT1041 GrabCut
//
//  Created by Jason Pan on 22/09/2016.
//  Copyright © 2016 Jason Pan. All rights reserved.
//

import UIKit

func radians(degrees: Double) -> Double { return degrees * M_PI/180 }
func radians(degrees: Int) -> Int { return Int(radians(Double(degrees))) }
func radians(degrees: CGFloat) -> CGFloat { return CGFloat(radians(Double(degrees))) }
let MAX_IMAGE_LENGTH: CGFloat = 450
//let MAX_IMAGE_LENGTH: CGFloat = 1000

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
        CGContextRotateCTM (bitmap, radians(90))
        CGContextTranslateCTM (bitmap, 0, -targetHeight)
        
    } else if sourceImage.imageOrientation == .Right {
        CGContextRotateCTM (bitmap, radians(-90))
        CGContextTranslateCTM (bitmap, -targetWidth, 0)
        
    } else if (sourceImage.imageOrientation == .Up) {
        // NOTHING
    } else if (sourceImage.imageOrientation == .Down) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight)
        CGContextRotateCTM (bitmap, radians(-180))
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef)
    if let ref: CGImageRef = CGBitmapContextCreateImage(bitmap) {
        let newImage = UIImage(CGImage: ref)
        return newImage
    }
    
    return nil
}

func resizeWithRotation_test(sourceImage: UIImage, rotationImage: UIImage) -> UIImage? {
    //let targetWidth: CGFloat = rotationImage.size.width
    //let targetHeight: CGFloat = rotationImage.size.height
    let targetWidth: CGFloat = sourceImage.size.width
    let targetHeight: CGFloat = sourceImage.size.height
    
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
        CGContextRotateCTM (bitmap, radians(90))
        CGContextTranslateCTM (bitmap, 0, -targetHeight)
        
    } else if rotationImage.imageOrientation == .Right {
        CGContextRotateCTM (bitmap, radians(-90))
        CGContextTranslateCTM (bitmap, -targetWidth, 0)
        
    } else if (rotationImage.imageOrientation == .Up) {
        // NOTHING
    } else if (rotationImage.imageOrientation == .Down) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight)
        CGContextRotateCTM (bitmap, radians(-180))
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef)
    if let ref: CGImageRef = CGBitmapContextCreateImage(bitmap) {
        let newImage = UIImage(CGImage: ref)
        return newImage
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
                                              CGImageGetDataProvider(maskRef), nil, false)
    
    if let masked: CGImageRef = CGImageCreateWithMask(sourceImage.CGImage, mask) {
        let maskedImage: UIImage = UIImage(CGImage: masked)
        return maskedImage
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
    
//    let black = RGBA32(red: 0, green: 0, blue: 0, alpha: 255)
    let black = RGBA32(red: 0, green: 0, blue: 0, alpha: 255)
    let white = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    let clear = RGBA32(red: 0, green: 0, blue: 0, alpha: 0)
    
    if shouldLogDebugOutput { print("a: \(currentPixel1)") }
    if shouldLogDebugOutput { print("b: \(currentPixel2)") }
    
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
//            if currentPixel1.memory.green != 0 {
//                print("test37281974632: |\(currentPixel1.memory)")
//            }
//            print("test74219843:: |\(currentPixel2.memory.green)")
//            print("test74219843:: \(currentPixel2.memory.red)   ||  \(currentPixel2.memory.green) || \(currentPixel2.memory.blue)")

            
            
            
            
//            if currentPixel2.memory.green > 100 && currentPixel2.memory.red < 150 && currentPixel2.memory.blue < 150 {
//                currentPixel2.memory = black
//            }
            
            
//            if currentPixel2.memory.green > 80 && currentPixel2.memory.red < 80 && currentPixel2.memory.blue < 80 {
//                currentPixel2.memory = black
//            }
////            else {
////                currentPixel2.memory = clear
////            }
            
            // greenDifference = greenChannel - (redChannel + blueChannel)/2
//            if currentPixel2.memory.green - ((currentPixel2.memory.red + currentPixel2.memory.blue) / 2) > 0 {
            
            
            let red = CGFloat(currentPixel2.memory.red)
            let green = CGFloat(currentPixel2.memory.green)
            let blue = CGFloat(currentPixel2.memory.blue)
            let average = (red + green + blue) / 3
            
            let condition = currentPixel2.memory.blue < 150 && currentPixel2.memory.red < 150
            let saturationCondition = abs(average - red) < 10 || abs(average - green) < 10 || abs(average - blue) < 10
            
            if currentPixel1.memory == black {
                currentPixel2.memory = black
            }else if currentPixel1.memory == white {
                currentPixel2.memory = clear
            }else if saturationCondition && average < 127 && shouldIsolateNeutrals {
//            }else if saturationCondition && average < 160 {
                currentPixel2.memory = black
            }else if green - ((red + blue) / 2) > 0 && condition {
                currentPixel2.memory = black
            }else {
                currentPixel2.memory = clear
            }
            
            
            
            
            
//            if currentPixel2.memory.red < 100 {
//                currentPixel1.memory = black
//            }else {
////                currentPixel1.memory = clear
//            }
            currentPixel1 += 1
            currentPixel2 += 1
        }
    }
    
    let outputCGImage = CGBitmapContextCreateImage(context2)
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

// See: http://stackoverflow.com/a/33260568/699963
extension UIImage {
    
    func fixOrientation() -> UIImage
    {
        
        if self.imageOrientation == UIImageOrientation.Up {
            return self
        }
        
        var transform = CGAffineTransformIdentity
        
        switch self.imageOrientation {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            
        case .Up, .UpMirrored:
            break
        }
        
        
        switch self.imageOrientation {
            
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        default:
            break
        }
        
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGBitmapContextCreate(
            nil,
            Int(self.size.width),
            Int(self.size.height),
            CGImageGetBitsPerComponent(self.CGImage),
            0,
            CGImageGetColorSpace(self.CGImage),
            UInt32(CGImageGetBitmapInfo(self.CGImage).rawValue)
        )
        
        CGContextConcatCTM(ctx, transform)
        
        switch self.imageOrientation {
            
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height,self.size.width), self.CGImage)
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width,self.size.height), self.CGImage)
            break
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = CGBitmapContextCreateImage(ctx)
        
        let img = UIImage(CGImage: cgimg!)
        
        //CGContextRelease(ctx)
        //CGImageRelease(cgimg)
        
        return img
        
    }
    
}
