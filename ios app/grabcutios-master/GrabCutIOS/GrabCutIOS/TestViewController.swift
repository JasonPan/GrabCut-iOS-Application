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
//  TestViewController.swift
//  FIT1041 GrabCut
//
//  Created by Jason Pan on 31/10/2016.
//  Copyright © 2016 Jason Pan. All rights reserved.
//

import UIKit

// This value needs to be greater than zero, since GrabCut needs some "working room" to perform the algorithm.
private let inset: CGFloat = 10

// This size is just used to improve testing performance.
private let downSamplingSize: CGSize = CGSizeMake(300, 300)

class TestViewController: UIViewController {
    
    var manager: GrabCutManager!
    var spinner: UIActivityIndicatorView?
    var dimmedView: UIView?
    
    
    @IBOutlet weak var sourceImageView: UIImageView!
    @IBOutlet weak var maskImageView: UIImageView!
    @IBOutlet weak var outputImageView: UIImageView!
    
    @IBAction func test() {
        
        // Some test images
//        self.imageView.image = UIImage(named: "test1.jpeg")
//        self.imageView.image = UIImage(named: "test.jpg")
        
        guard var image = self.sourceImageView.image else {
            return
        }
        
        // Downsamplying for performance
        image = resizeImage(image, size: downSamplingSize)
        
        self.sourceImageView.image = image
        self.maskImageView.image = image
        self.outputImageView.image = image
        
        self.showLoadingIndicatorView()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let foregroundRect = CGRect(origin: CGPointZero, size: CGSizeMake(image.size.width - inset,image.size.height - inset))
            let output = self.manager.doGrabCut(image, foregroundBound: foregroundRect, iterationCount: 5)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.hideLoadingIndicatorView()
                self.maskImageView.image = output
                self.outputImageView.image = masking(image, mask: output)
            })
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.manager = GrabCutManager()
        self.manager.resetManager()
        
        self.sourceImageView.layer.borderColor = UIColor.redColor().CGColor
        self.sourceImageView.layer.borderWidth = 1
        
        self.maskImageView.layer.borderColor = UIColor.redColor().CGColor
        self.maskImageView.layer.borderWidth = 1
        
        self.outputImageView.layer.borderColor = UIColor.redColor().CGColor
        self.outputImageView.layer.borderWidth = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Indicator
    
    func CGRectSetOrigin(rect: CGRect, _ origin: CGPoint) -> CGRect {
        var rect = rect
        rect.origin = origin
        return rect
    }
    
    func showLoadingIndicatorView() {
        self.showLoadingIndicatorViewWithStyle(.White)
    }
    
    func showLoadingIndicatorViewWithStyle(activityIndicatorViewStyle: UIActivityIndicatorViewStyle) {
        if self.spinner != nil {
            self.hideLoadingIndicatorView()
        }
        
        self.dimmedView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        self.dimmedView?.backgroundColor = UIColor.init(red:0, green:0, blue:0, alpha:0.7)
        self.view.addSubview(self.dimmedView!)
        
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: activityIndicatorViewStyle)
        spinner.frame = CGRectSetOrigin(spinner.frame, CGPointMake(floor(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(spinner.bounds)), floor(CGRectGetMidY(self.view.bounds) - CGRectGetMidY(spinner.bounds))))
        spinner.autoresizingMask = [.FlexibleLeftMargin,.FlexibleRightMargin,.FlexibleTopMargin,.FlexibleBottomMargin]
        spinner.startAnimating()
        self.view.addSubview(spinner)
        self.spinner = spinner
        
        self.view.userInteractionEnabled = false
    }
    
    func hideLoadingIndicatorView() {
        self.spinner?.stopAnimating()
        self.spinner?.removeFromSuperview()
        self.spinner = nil
        
        self.dimmedView?.removeFromSuperview()
        self.dimmedView = nil
        
        self.view.userInteractionEnabled = true
    }

}
