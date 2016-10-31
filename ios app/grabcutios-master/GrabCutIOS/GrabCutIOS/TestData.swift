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
//  TestData.swift
//  FIT1041 GrabCut
//
//  Created by Jason Pan on 31/10/2016.
//  Copyright © 2016 Jason Pan. All rights reserved.
//

import Foundation

class TestImageSequenceData {
    
    //*********************************************************************************************************
    // MARK: - Test data serialization
    //*********************************************************************************************************
    
    static let selectedDataFormat: Int = 1
    
    // Specify the data formats used for testing.
    //
    // @param sequenceCount The number of images in the sequence
    // @param prefixIdentifier The prefix that identifies the images that belong to a sequence.
    // @param indexIndentifier An identifier, in '#'s, that indicates the index of an image in a sequence.
    //
    // Example: Image sequence consisting of 4 images with filenames:
    //
    //      'test-data01.png',
    //      'test-data02.png',
    //      'test-data03.png',
    //      'test-data04.png'.
    //
    // Format: (4, "test-data", "##", "png")
    //
    // NOTE: All image sequences are assumed strictly sequential and start with an index of 1.
    //
    typealias DataFormat = (sequenceCount: Int, prefixIdentifier: String, indexIndentifier: String, fileExtension:String)
    static let dataFormats: [DataFormat] = [(3, "test", "#", "jpeg"),
                                     (8, "v2_tb2-", "###", "jpeg")]
    
    static var numberOfImages: Int {
        return dataFormats[selectedDataFormat].0
    }
    
    static  var filenameFormat: String {
        let format: DataFormat = dataFormats[selectedDataFormat]
        return "\(format.1)\(filenameIndexSpecifier).\(format.fileExtension)"
    }
    
    // Used to find the index of a particular image in a sequence, represented by '#'s.
    static var filenameIndexSpecifier: String {
        return dataFormats[selectedDataFormat].2
        
    }
    
    static func filenameIndexWithIndex(index: Int) -> String {
        return String(format: "%0\(filenameIndexSpecifier.characters.count)d", index)
    }
    
    static func filename(index: Int) -> String {
        if shouldLogDebugOutput { print("test 5542a: \(filenameIndexWithIndex(index))") }
        let retVal = filenameFormat.stringByReplacingOccurrencesOfString(filenameIndexSpecifier, withString: filenameIndexWithIndex(index))
        if shouldLogDebugOutput { print(retVal) }
        return retVal
    }
}
