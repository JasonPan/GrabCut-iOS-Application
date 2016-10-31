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
//  GrabCutManager.h
//  OpenCVTest
//
//  Created by EunchulJeon on 2015. 8. 29..
//  Copyright (c) 2015 Naver Corp.
//  @Author Eunchul Jeon, Jason Pan
//
//  Originally written by Eunchul Jeon, Naver Corp.
//  https://github.com/naver/grabcutios
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/// This class is a wrapper that exposes the GrabCut APIs from the OpenCV C++ framework,
/// providing an interface for the Swift compiler to use.
@interface GrabCutManager : NSObject

/**
 @brief Runs the GrabCut algorithm. Operation mode is GC_INIT_WITH_RECT, which performs the 'initial segmentation'.
 The function implements the [GrabCut image segmentation algorithm](http://en.wikipedia.org/wiki/GrabCut).
 
 @param sourceImage Input 8-bit 3-channel image.
 
 @param foregroundBound ROI containing a segmented object. The pixels outside of the ROI are marked as
 "obvious background". The parameter is only used when mode==GC_INIT_WITH_RECT .
 
 @param iterationCount Number of iterations the algorithm should make before returning the result. Note
 that the result can be refined with further calls with mode==GC_INIT_WITH_MASK or
 mode==GC_EVAL .
 
 @return A binary mask image with foreground marked in black, and background marked in white. 
 */
-(UIImage*) doGrabCut:(UIImage*)sourceImage foregroundBound:(CGRect) rect iterationCount:(int)iterCount;

/**
 @brief Runs the GrabCut algorithm. Operation mode is GC_INIT_WITH_RECT, which performs the 'initial segmentation'.
 The function implements the [GrabCut image segmentation algorithm](http://en.wikipedia.org/wiki/GrabCut).
 
 @param sourceImage Input 8-bit 3-channel image.
 
 @param maskImage Input/output 8-bit single-channel mask. The mask is initialized by the function when
 mode is set to GC_INIT_WITH_RECT. Its elements may have one of the cv::GrabCutClasses.
 
 @param iterationCount Number of iterations the algorithm should make before returning the result. Note
 that the result can be refined with further calls with mode==GC_INIT_WITH_MASK or
 mode==GC_EVAL .
 
 @return A binary mask image with foreground marked in black, and background marked in white.
 */
-(UIImage*) doGrabCutWithMask:(UIImage*)sourceImage maskImage:(UIImage*)maskImage iterationCount:(int) iterCount;

/**
 @brief Resets the manager, discarding any previous existing models used by GrabCut.
 
 @return N/A
 */
-(void) resetManager;
@end
