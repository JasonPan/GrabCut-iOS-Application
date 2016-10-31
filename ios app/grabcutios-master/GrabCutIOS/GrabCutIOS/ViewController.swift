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
//  ViewController.swift
//  FIT1041 GrabCut
//
//  Created by Jason Pan on 22/09/2016.
//  Copyright © 2016 Jason Pan. All rights reserved.
//
//  Originally written by Eunchul Jeon, Naver Corp.
//  https://github.com/naver/grabcutios
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //*********************************************************************************************************
    // MARK: - Instance variables
    //*********************************************************************************************************
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var touchDrawView: TouchDrawView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var rectButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var doGrabcutButton: UIButton!
    
    // Position tracking for drawing the bounding rectangle.
    var startPoint: CGPoint!
    var endPoint: CGPoint!
    
    // GrabCut and image processing
    var grabcut: GrabCutManager! // The manager exposes OpenCV GrabCut implementation
    var touchState: TouchState = .None // Tracks the current touch state i.e. foreground/background labelling, drawing bounding rect, ...
    var grabRect: CGRect = CGRectNull // Bounding rect
    var originalImage: UIImage!
    var resizedImage: UIImage!
    var imagePicker: UIImagePickerController?
    
    // Background progressing UI
    var spinner: UIActivityIndicatorView?
    var dimmedView: UIView?
    
    // Automated GrabCut processing on image sequences (performed on start-up, see TestData.swift for specification details).
    var i: Int = 1
    var timer: NSTimer?
    var cachedMaskImage: UIImage?
    var inAutoMode: Bool = true // Used to detect initial image sequence processing status. (subsequent image selection from the photo library will not allow image sequences, only individual photos).
    
    var hasBegunInteraction: Bool = false
    var hasSpecifiedBoundingRect: Bool = false
    //    var hasSpecifiedForegroundLabels: Bool = false
    //    var hasSpecifiedBackgroundLabels: Bool = false
    var hasSpecifiedLabels: Bool = false
    var shouldPause: Bool {
        return !hasSpecifiedBoundingRect || !hasSpecifiedLabels
    }
    var origArr: [UIImage]! // Contains source images in sequence.
    var resArr: [UIImage]!  // Contains results from source images in sequence.
    
    //*********************************************************************************************************
    // MARK: - Instance methods (Automated GrabCut processing on image sequences)
    //*********************************************************************************************************
    
    // Automate bounds selection by selecting viewable screen bounds (inc. GrabCut "working space" + 64 pts for nav and status bar)
    func autoselectBoundingRect() {
        self.tapOnRect(self)
        self.touchState = .Rect
        let fullRect = CGRect(origin: CGPointMake(20, 20), size: CGSizeMake(self.touchDrawView.bounds.width, self.touchDrawView.bounds.height+64))
        self.grabRect = fullRect
        self.touchDrawView.drawRectangle(fullRect)
        self.tapOnDoGrabcut(self)
        
    }
    
    func displaySequenceResults() {
        let cond: Bool = !CGRectIsNull(self.grabRect) && !CGRectIsEmpty(self.grabRect)
        
        if (shouldPause || !cond) {
            return
        }
        
        i += 1
        
        if (i > TestImageSequenceData.numberOfImages) {
            i = 1
        }
        
        
        if shouldLogDebugOutput { print("shouldPause: \(shouldPause)  ||  \(i)  ||  \(self.resArr[i - 1])") }
        
        self.tapOnReset("nil")
        
        self.imageView.image = self.origArr[i - 1]
        self.resultImageView.image = self.resArr[i - 1]
        self.imageView.alpha = 0.2
    }
    
    func performGrabCutForSequenceImage(image: UIImage) {
        
        self.tapOnReset("nil")
        
        self.setImageToTarget(image)
        
        self.tapOnRect("nil")
        
        if (!CGRectIsNull(self.grabRect) && !CGRectIsEmpty(self.grabRect)) {
            self.tapOnMinus("nil")
//            self.hasSpecifiedLabels = true
            NSLog("processing image...")
            self.tapOnDoGrabcut("nil")
        }
    }
    
    //*********************************************************************************************************
    // MARK: - Testing
    //*********************************************************************************************************
    
    // Save images for debugging / testing / viewing
    func saveSampleImage(image: UIImage) {
        
        guard shouldSaveResults == true else {
            return
        }
        
        let sourceImage: UIImage = colourisedImageWithImage(self.originalImage, colour: UIColor.redColor())
        let segmentedImage: UIImage = colourisedImageWithImage(image, colour: UIColor.redColor())
        
        let filename = randomString(10)
        if let data = UIImagePNGRepresentation(sourceImage) {
            let filename = getDocumentsDirectory().URLByAppendingPathComponent("\(filename).png")
            let _ = try? data.writeToURL(filename, options: NSDataWritingOptions(rawValue: 0))
        }
        
        if let data = UIImagePNGRepresentation(segmentedImage) {
            let filename = getDocumentsDirectory().URLByAppendingPathComponent("\(filename)-segmented.png")
            let _ = try? data.writeToURL(filename, options: NSDataWritingOptions(rawValue: 0))
        }
    }
    
    //*********************************************************************************************************
    // MARK: - Instance methods
    //*********************************************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("Debug sample image data will be output to:\n   \(getDocumentsDirectory().absoluteString)\n\n")
        
        // Initialize the GrabCut manager
        self.grabcut = GrabCutManager()
        
        self.initStates()
        
        // Set up initial segmentation of image sequence objects.
        self.performGrabCutForSequenceImage(UIImage(named: TestImageSequenceData.filename(i))!)
        
        // Automatically select a bounding rect (~~view size, can't be complete bounds since GrabCut requires "working room")
        self.autoselectBoundingRect()
        
        // Carry out appropriate UI updates automatically (since this is a sequence).
        self.tapOnMinus(self)
        self.touchDrawView.touchStarted(CGPointZero)
        self.touchDrawView.touchEnded(CGPointZero)
        self.doGrabcutButton.enabled = true
        
        // Load and process sequence images
        if resArr == nil {
            resArr = []
            origArr = []
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                for i in 0 ..< TestImageSequenceData.numberOfImages {
                    
                    while (self.resultImageView.image == nil) {}
                    while (self.shouldPause) {}
                    
                    guard self.inAutoMode == true else {
                        return
                    }
                    
                    dispatch_sync(dispatch_get_main_queue(), {
                        self.resultImageView.image = nil
                        
                        let filename = TestImageSequenceData.filename(i+1)
                        if self.inAutoMode {
                            self.performGrabCutForSequenceImage(UIImage(named: filename)!)
                            self.origArr.append(self.originalImage)
                        }
                    })
                    
                    while (self.resultImageView.image == nil) {}
                    
                    if self.inAutoMode {
                        self.resArr.append(self.resultImageView.image!)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if self.inAutoMode {
                        self.touchDrawView.clearForReal() // Clear any labelling that was done.
                        
                        self.i = 1 // Start at image with sequence index 1.
                        
                        // This will loop through all results from images in sequence.
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.displaySequenceResults), userInfo: nil, repeats: true)
                    }
                })
            })
        }
    }
    
    func initStates() {
        self.touchState = .None
        self.updateStateLabel()
        
        self.rectButton.enabled = true
        self.plusButton.enabled = false
        self.minusButton.enabled = false
        self.doGrabcutButton.enabled = false
    }
    
    func getProperResizedImage(original: UIImage) -> UIImage? {
        let ratio: CGFloat = original.size.width / original.size.height
        
        if original.size.width > original.size.height {
            if original.size.width > MAX_IMAGE_LENGTH {
                return resizeWithRotation(original, size: CGSizeMake(MAX_IMAGE_LENGTH, MAX_IMAGE_LENGTH/ratio))
            }
        }else {
            if original.size.height > MAX_IMAGE_LENGTH {
                return resizeWithRotation(original, size: CGSizeMake(MAX_IMAGE_LENGTH*ratio, MAX_IMAGE_LENGTH))
            }
        }
        
        return original
    }
    
    func getTouchStateToString() -> String {
        let state: String = "Touch State : "
        var suffix: String
        
        switch self.touchState {
        case .None:
            suffix = "None"
            break
        case .Rect:
            suffix = "Rect"
            break
        case .Plus:
            suffix = "Plus"
            break
        case .Minus:
            suffix = "Minus"
            break
        }
        
        return "\(state)\(suffix)"
    }
    
    func updateStateLabel() {
        self.stateLabel.text = self.getTouchStateToString()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTouchedRectWithImageSize(size: CGSize) -> CGRect {
        let widthScale: CGFloat = size.width/self.imageView.frame.size.width
        let heightScale: CGFloat = size.height/self.imageView.frame.size.height
        return self.getTouchedRect(self.startPoint, endPoint: self.endPoint, widthScale: widthScale, heightScale: heightScale)
    }
    
    func getTouchedRect(startPoint: CGPoint, endPoint: CGPoint) -> CGRect {
        return self.getTouchedRect(startPoint, endPoint: endPoint, widthScale: 1.0, heightScale: 1.0)
    }
    
    func getTouchedRect(startPoint: CGPoint, endPoint: CGPoint, widthScale: CGFloat, heightScale: CGFloat) -> CGRect {
        let minX: CGFloat = startPoint.x > endPoint.x ? endPoint.x*widthScale : startPoint.x*widthScale
        let maxX: CGFloat = startPoint.x < endPoint.x ? endPoint.x*widthScale : startPoint.x*widthScale
        let minY: CGFloat = startPoint.y > endPoint.y ? endPoint.y*heightScale : startPoint.y*heightScale
        let maxY: CGFloat = startPoint.y < endPoint.y ? endPoint.y*heightScale : startPoint.y*heightScale
        
        return CGRectMake(minX, minY, maxX - minX, maxY - minY)
    }
    
    func doGrabcut() {
        self.showLoadingIndicatorView()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var resultImage: UIImage! = self.grabcut.doGrabCut(self.resizedImage, foregroundBound: self.grabRect, iterationCount: 5)
            resultImage = masking(self.originalImage, mask: resizeImage(resultImage, size: self.originalImage.size))
            
            dispatch_async(dispatch_get_main_queue(), {
                self.resultImageView.image = resultImage
                self.imageView.alpha = 0.2
                self.resultImageView.backgroundColor = UIColor.redColor()
                
                self.hideLoadingIndicatorView()
                
                if shouldSaveResults {
                    
                    self.resultImageView.image = resultImage.imageWithAlpha(1.0)
                    
                    guard let image = self.resultImageView.image else {
                        return
                    }
                    
                    // Output results to disk for debugging / testing.
                    self.saveSampleImage(image)
                }
            })
        })
    }
    var count = 0
    func doGrabcutWithMaskImage(image: UIImage) {
        self.showLoadingIndicatorView()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let sourceImage = self.resizedImage
            let maskImage = resizeImage(image, size: self.resizedImage.size)
            
            var resultImage: UIImage! = self.grabcut.doGrabCutWithMask(sourceImage, maskImage: maskImage, iterationCount: 5)
            if shouldLogDebugOutput { print(self.originalImage.size) }
            
            resultImage = resizeImage(resultImage, size: self.originalImage.size)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.resultImageView.image = resultImage
                self.imageView.alpha = 0.2
                self.hideLoadingIndicatorView()
                
                if shouldSaveResults {
                    guard let image = self.resultImageView.image else {
                        return
                    }
                    
                    // Output results to disk for debugging / testing.
                    self.saveSampleImage(image)
                }
            })
        })
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSLog("began")
        
        hasBegunInteraction = true
        
//        shouldPause = true
        
        let touch: UITouch? = touches.first
        self.startPoint = touch?.locationInView(self.imageView)
        
        if self.touchState == .None || self.touchState == .Rect {
            self.touchDrawView.clear()
        }else if self.touchState == .Plus || self.touchState == .Minus {
            self.touchDrawView.touchStarted(self.startPoint)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSLog("moved")
        let touch: UITouch? = touches.first
        let point: CGPoint! = touch?.locationInView(self.imageView)
        
        if self.touchState == .Rect {
            let rect: CGRect = self.getTouchedRect(self.startPoint, endPoint:point)
            self.touchDrawView.drawRectangle(rect)
        }else if self.touchState == .Plus || self.touchState == .Minus {
            self.touchDrawView.touchMoved(point)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSLog("ended")
        let touch: UITouch? = touches.first
        self.endPoint = touch?.locationInView(self.imageView)
        
        if self.touchState == .Rect {
            self.grabRect = self.getTouchedRectWithImageSize(self.resizedImage.size)
        }else if self.touchState == .Plus || self.touchState == .Minus {
            self.touchDrawView.touchEnded(self.endPoint)
            self.doGrabcutButton.enabled = true
        }
    }
    
    @IBAction func tapOnReset(sender: AnyObject) {
        self.imageView.image = self.originalImage
        self.resultImageView.image = nil
        self.imageView.alpha = 1.0
        self.touchState = .None
        self.updateStateLabel()
        
        self.rectButton.enabled = true
        self.plusButton.enabled = false
        self.minusButton.enabled = false
        self.doGrabcutButton.enabled = false
        
//        self.plusButton.enabled = true
//        self.minusButton.enabled = true
//        self.doGrabcutButton.enabled = false
        
//        self.touchDrawView.clear()
//        self.grabcut.resetManager()
        
        if !inAutoMode {
            
            self.touchDrawView.clear()
            self.grabcut.resetManager()
        }
    }
    
    @IBAction func tapOnRect(sender: AnyObject) {
        self.touchState = .Rect
        self.updateStateLabel()
        
        self.plusButton.enabled = false
        self.minusButton.enabled = false
        self.doGrabcutButton.enabled = true
        
//        self.plusButton.enabled = true
//        self.minusButton.enabled = true
//        self.doGrabcutButton.enabled = true
    }
    
    @IBAction func tapOnPlus(sender: AnyObject) {
        self.touchState = .Plus
        self.updateStateLabel()
        
//        self.touchDrawView.setCurrentState(.Plus)
        self.touchDrawView.currentState = .Plus
    }
    
    @IBAction func tapOnMinus(sender: AnyObject) {
        self.touchState = .Minus
        self.updateStateLabel()
        
//        self.touchDrawView.setCurrentState(.Minus)
        self.touchDrawView.currentState = .Minus
    }
    
    @IBAction func tapOnDoGrabcut(sender: AnyObject) {
        
//        shouldPause = false
        
        if self.touchState == .Rect {
            if self.isUnderMinimumRect() {
                let alert = UIAlertController(title: "Opps", message: "More bigger rect for operation", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                return
            }
            
            hasSpecifiedBoundingRect = true
            
            self.doGrabcut()
            self.touchDrawView.clear()
            self.touchDrawView.clearForReal()
            
            self.rectButton.enabled = false
            self.plusButton.enabled = true
            self.minusButton.enabled = true
            self.doGrabcutButton.enabled = false
        }else if self.touchState == .Plus || self.touchState == .Minus {
            
            var touchedMask: UIImage! = self.touchDrawView.maskImageWithPainting()
            
            if sender as? String == "nil" {
                
                if shouldIsolateGreen {
                    
                    // Combines user labelling with automated green labelling.
                    touchedMask = combineMaskImages(touchedMask, maskImage2: self.originalImage)
                    
                    self.grabcut.resetManager()
                    self.grabcut.doGrabCut(self.resizedImage, foregroundBound: self.grabRect, iterationCount: 5)
                }
                
                cachedMaskImage = touchedMask
                self.doGrabcutWithMaskImage(cachedMaskImage!)
//                self.touchDrawView.clearForReal()
            }else {
                
                if !self.shouldPause || !inAutoMode {
                    
                    if shouldIsolateGreen {
                        
                        // Combines user labelling with automated green labelling.
                        touchedMask = combineMaskImages(touchedMask, maskImage2: self.originalImage)
                    }
                    
//                    self.resultImageView.image = touchedMask
//                    return
//                    print("321: success")
                    
                    self.doGrabcutWithMaskImage(touchedMask)
                    self.touchDrawView.clearForReal()
                }
            }
//            self.resultImageView.backgroundColor = UIColor.orangeColor()
            self.hasSpecifiedLabels = true
            
            self.rectButton.enabled = false
            self.plusButton.enabled = true
            self.minusButton.enabled = true
            self.doGrabcutButton.enabled = true
        }
    }
    
    @IBAction func tapOnSave(sender: AnyObject) {
        guard let image = self.resultImageView.image else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        UIImageWriteToSavedPhotosAlbum(self.imageView.image!, nil, nil, nil)
        
        let alert = UIAlertController(title: "Saved!", message: "Image was saved to photo library.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func isUnderMinimumRect() -> Bool {
        if self.grabRect.size.width < 20.0 || self.grabRect.size.height < 20.0 {
            return true
        }
        return false
    }
    
    // MARK: - Image Picker
    
    @IBAction func tapOnPhoto(sender: AnyObject) {
        self.startMediaBrowserFromViewController(self, usingDelegate: self)
        timer?.invalidate()
    }
    
    @IBAction func tapOnCamera(sender: AnyObject) {
        self.startCameraControllerFromViewController(self, usingDelegate: self)
        timer?.invalidate()
    }
    
    func setImageToTarget(image: UIImage) {
        if shouldLogDebugOutput { print("target_image_res: \(image.size)") }
        let image = image.fixOrientation()
        self.originalImage = resizeWithRotation(image, size: image.size)
//        self.originalImage = image
        if shouldLogDebugOutput { print("orig_image_res: \(self.originalImage.size)") }
        self.resizedImage = self.getProperResizedImage(self.originalImage)
        self.imageView.image = self.originalImage
        self.initStates()
        
        if !inAutoMode {// || (shouldIsolateGreen && self.originalImage != nil) {
            self.grabcut.resetManager()
        }
//        self.grabcut.resetManager()
    }
    
    func startCameraControllerFromViewController(controller: UIViewController?, usingDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>?) -> Bool {
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) == false || delegate == nil || controller == nil {
            return false
        }
        
        self.imagePicker = UIImagePickerController()
        self.imagePicker?.sourceType = .Camera
        
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        //    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]
        self.imagePicker?.mediaTypes = [kUTTypeImage as String]
        
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        self.imagePicker?.allowsEditing = false
        
        self.imagePicker?.delegate = delegate
        
        controller?.presentViewController(self.imagePicker!, animated: true, completion: nil)
        return true
    }
    
//    func startMediaBrowserFromViewController<T: AnyObject where T: UIImagePickerControllerDelegate>(controller: UIViewController, usingDelegate delegate: T) {
    func startMediaBrowserFromViewController(controller: UIViewController?, usingDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>?) -> Bool {
        
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) == false || delegate == nil || controller == nil {
            return false
        }
        
        self.imagePicker = UIImagePickerController()
        //    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum
        self.imagePicker?.sourceType = .PhotoLibrary
        
        // Displays saved pictures and movies, if both are available, from the
        // Camera Roll album.
        self.imagePicker?.mediaTypes = [kUTTypeImage as String]
        //    [UIImagePickerController availableMediaTypesForSourceType:
        //     UIImagePickerControllerSourceTypeSavedPhotosAlbum]
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        self.imagePicker?.allowsEditing = false
        
        self.imagePicker?.delegate = delegate
        
        controller?.presentViewController(self.imagePicker!, animated: true, completion: nil)
        return true
    }
    
    //*********************************************************************************************************
    // MARK: - UIImagePickerControllerDelegate
    //*********************************************************************************************************
    
    // For responding to the user tapping Cancel.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.imagePicker?.dismissViewControllerAnimated(true, completion: nil)
        self.imagePicker = nil
    }
    
    // For responding to the user accepting a newly-captured picture or movie
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType: NSString! = info[UIImagePickerControllerMediaType] as? NSString
        var originalImage: UIImage!, editedImage: UIImage!, resultImage: UIImage!
        
        if CFStringCompare (mediaType as CFStringRef, kUTTypeImage as CFStringRef, CFStringCompareFlags(rawValue: 0))
            == CFComparisonResult.CompareEqualTo {
            
            editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
            originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            if editedImage != nil {
                resultImage = editedImage
            } else {
                resultImage = originalImage
            }
        }
        
        inAutoMode = false
        
        self.tapOnReset("nil")
        
        let taskBlock = {
            self.setImageToTarget(resultImage)
            
            self.imagePicker?.dismissViewControllerAnimated(true, completion: nil)
            self.imagePicker = nil
            
            // Automatically select a bounding rect (~~view size, can't be complete bounds since GrabCut requires "working room")
            self.autoselectBoundingRect()
            
            // Carry out appropriate UI updates automatically (since this is a sequence).
            self.tapOnMinus(self)
            self.touchDrawView.touchStarted(CGPointZero)
            self.touchDrawView.touchEnded(CGPointZero)
            self.doGrabcutButton.enabled = true
        }
        
        if resizedImage != nil && self.originalImage != nil && resultImage != nil {
//            print("passed test 4567382")
            if shouldLogDebugOutput { print("passed test 4567382: \(self.originalImage.size)  ||  \(resultImage.size)") }
            
            if self.originalImage.size != resultImage.size {
                if shouldLogDebugOutput { print("passed test idu261: \(self.originalImage.size)  ||  \(resultImage.size)") }
                taskBlock()
                
                // Automatically perform GrabCut.
                // Note: This can be disabled to allow labelling before the initial segmentation is performed.
                self.showLoadingIndicatorView()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    repeat {} while self.resultImageView.image == nil
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hideLoadingIndicatorView()
                        self.tapOnDoGrabcut(self)
                    })
                })
                
                return
            }
        }
        
        taskBlock()
        
//        self.tapOnRect("nil")
        
        if (!CGRectIsNull(self.grabRect) && !CGRectIsEmpty(self.grabRect)) {
//            self.touchState = .Minus // .Plus Or .Minus, either-or
            self.tapOnMinus("nil")
            NSLog("processing image...")
            self.tapOnDoGrabcut("nil")
        }
    }
    
    //*********************************************************************************************************
    // MARK: - Load Indicator
    //*********************************************************************************************************
    
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
