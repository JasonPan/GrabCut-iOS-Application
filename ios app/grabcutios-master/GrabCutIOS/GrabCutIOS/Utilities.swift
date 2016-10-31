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
//  Utilities.swift
//  FIT1041 GrabCut
//
//  Created by Jason Pan on 6/10/2016.
//  Copyright © 2016 Jason Pan. All rights reserved.
//

import Foundation

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
