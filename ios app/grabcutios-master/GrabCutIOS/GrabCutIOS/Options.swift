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
//  Options.swift
//  FIT1041 GrabCut
//
//  Created by Jason Pan on 31/10/2016.
//  Copyright © 2016 Jason Pan. All rights reserved.
//

import Foundation

// Saves results to local application folder. This is usually used for the simulator (since the folder is easily accessible).
// The file path will be printed in the console when the app starts up.
let shouldSaveResults: Bool = true

let shouldIsolateGreen: Bool = true
let shouldIsolateNeutrals: Bool = false // This tends to be unstable. Further testing required. You have been warned.

let shouldLogDebugOutput: Bool = false // Log debug output
//@objc public class Options: NSObject {
//    @objc public static let shouldLogGrabCutOutput: Bool = false // Log GrabCut output
//    
//    @objc public class func test() -> Bool {
//        return false
//    }
//    
//    override init() {
//        super.init()
//    }
//    
//}
