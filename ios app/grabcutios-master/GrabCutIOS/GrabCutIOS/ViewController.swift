//
//  ViewController.swift
//  FIT1041 GrabCut
//
//  Created by Jason @ Monash on 22/09/2016.
//  Copyright © 2016 Jason Pan. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let shouldIsolateGreen: Bool = false
    
    let selectedDataFormat: Int = 1
    let dataFormats: [(Int, String, String)] = [(3, "test", "#"),
                                                (8, "v2_tb2-", "###")]
    
//    let numberOfImages = 3
//    let numberOfImages = 8
    var numberOfImages: Int {
        return dataFormats[selectedDataFormat].0
    }
    
    var filenameFormat: String {
//        let filename = "test\(i).jpeg"
//        return "test###.jpeg"
//        return "test\(filenameIndexSpecifier).jpeg"
//        return "v2_tb2-\(filenameIndexSpecifier).jpeg"
        return "\(dataFormats[selectedDataFormat].1)\(filenameIndexSpecifier).jpeg"
    }
    
    var filenameIndexSpecifier: String {
//        return "#"
//        return "###"
        return dataFormats[selectedDataFormat].2
        
    }
    
    func filenameIndexWithIndex(index: Int) -> String {
//        var retVal = "\(index)"
//        retVal = String(format: "%02d", index)
//        
//        return "###"
//        let form = "%0\(filenameIndexSpecifier.characters.count)d"
//        print(form)
        return String(format: "%0\(filenameIndexSpecifier.characters.count)d", index)
//        return String(format: form, index)
    }
    
    func filename(index: Int) -> String {
//        print(filenameIndexWithIndex(index))
        let retVal = filenameFormat.stringByReplacingOccurrencesOfString(filenameIndexSpecifier, withString: filenameIndexWithIndex(index))
        print(retVal)
        return retVal
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    var startPoint: CGPoint!
    var endPoint: CGPoint!
    @IBOutlet weak var touchDrawView: TouchDrawView!
    var grabcut: GrabCutManager!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var rectButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var doGrabcutButton: UIButton!
    var touchState: TouchState = .None
    var grabRect: CGRect = CGRectNull
    var originalImage: UIImage!
    var resizedImage: UIImage!
    var imagePicker: UIImagePickerController?
    
    var spinner: UIActivityIndicatorView?
    var dimmedView: UIView?
    
    var i: Int = 1
    var timer0: NSTimer?
    var timer: NSTimer?
    var cachedMaskImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.grabcut = GrabCutManager()
        
//        self.originalImage = UIImage(named: "test.jpg")
//        self.resizedImage = self.getProperResizedImage(self.originalImage)
        
        self.initStates()
        
        //    [self testUsingImage:[UIImage imageNamed:@"test1.jpeg"]];
//        self.testUsingImage(UIImage(named: filename)!)
        
        
        
//        self.imageView.image = processPixelsInImage(UIImage(named: filename(i))!)
        
        self.testUsingImage(UIImage(named: filename(i))!)
        
        
//            timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(test1) userInfo:nil repeats:true];
        
        //    timer0 = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(test1) userInfo:nil repeats:true];
        timer0 = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.test1), userInfo: nil, repeats: true)

        if resArr == nil {
            resArr = []
            origArr = []
            
            //        [timer invalidate];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                for i in 0 ..< self.numberOfImages {
                    
                    
                    while (self.resultImageView.image == nil) {}
                    while (self.shouldPause) {}
                    self.timer0?.invalidate()
                    
                    dispatch_sync(dispatch_get_main_queue(), {
                        self.resultImageView.image = nil
                    })
                    
//                    let filename = "test\(i+1).jpeg"
                    let filename = self.filename(i+1)
//                    self.testUsingImage(UIImage(named: filename)!)
                    dispatch_sync(dispatch_get_main_queue(), {
                        self.testUsingImage(UIImage(named: filename)!)
                        self.origArr.append(self.originalImage)
                    })
                    
                    while (self.resultImageView.image == nil) {}
                    
                    self.timer0?.invalidate()
                    
                    self.resArr.append(self.resultImageView.image!)
//                    self.origArr.append(UIImage(named: filename)!)
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.i = 1;
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.test), userInfo: nil, repeats: true)
                })
            })
            
            //        for (int i = 0; i < 3; i++) {
            //
            //            self.resultImageView.image = nil;
            //
            //            NSString *filename = [NSString stringWithFormat:@"test%i.jpeg", i+1];
            //            [self testUsingImage:[UIImage imageNamed:filename]];
            //
            //            while (self.resultImageView.image == nil) {}
            //
            //            [resArr addObject:self.resultImageView.image];
            //        }
        }
        
        //    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(test) userInfo:nil repeats:true];
    }
    
    var hasBegunInteraction: Bool = false
    var hasSpecifiedBoundingRect: Bool = false
//    var hasSpecifiedForegroundLabels: Bool = false
//    var hasSpecifiedBackgroundLabels: Bool = false
    var hasSpecifiedLabels: Bool = false
    var shouldPause: Bool {
        return !hasSpecifiedBoundingRect || !hasSpecifiedLabels
    }
//    var resArr: NSMutableArray!
    var resArr: [UIImage]!
    var origArr: [UIImage]!
    
    func test1() {
        
        if hasBegunInteraction {
//        if (shouldPause) {
            return;
        }
        
        i += 1;
        
        if (i > numberOfImages) {
            i = 1;
        }
        
        //    [self tapOnReset:nil];
//        let filename = "test\(i).jpeg"
        let filename = self.filename(i)
        //    [self setImageToTarget:[UIImage imageNamed:filename]];
        self.testUsingImage(UIImage(named: filename)!)
    }
    
    func test() {
        
//        let cond: Bool = true//!CGRectIsNull(self.grabRect) && !CGRectIsEmpty(self.grabRect);
        let cond: Bool = !CGRectIsNull(self.grabRect) && !CGRectIsEmpty(self.grabRect);
        
//        print("shouldPause: \(shouldPause)  ||  \(i)  ||  \(self.resArr[i])")
        
        if (shouldPause || !cond) {
            
            //        //    [self tapOnReset:nil];
            //        NSString *filename = [NSString stringWithFormat:@"test%i.jpeg", i];
            //        //    [self setImageToTarget:[UIImage imageNamed:filename]];
            //        [self testUsingImage:[UIImage imageNamed:filename]];
            
            return;
        }
        
        timer0?.invalidate()
        
        i += 1;
        
        if (i > numberOfImages) {
            i = 1;
        }
        
        
        print("shouldPause: \(shouldPause)  ||  \(i)  ||  \(self.resArr[i - 1])")
        
        //
        //    NSString *filename = [NSString stringWithFormat:@"test%i.jpeg", i];
        //    [self testUsingImage:[UIImage imageNamed:filename]];
        
        //    if (resArr == NULL) {
        //        resArr = [NSMutableArray array];
        //
        //        for (int i = 0; i < 3; i++) {
        //
        //            self.resultImageView.image = nil;
        //
        //            NSString *filename = [NSString stringWithFormat:@"test%i.jpeg", i+1];
        //            [self testUsingImage:[UIImage imageNamed:filename]];
        //
        //            while (self.resultImageView.image == nil) {}
        //
        //            [resArr addObject:self.resultImageView.image];
        //        }
        //    }
        
        self.tapOnReset("nil")
        //    NSString *filename = [NSString stringWithFormat:@"test%i.jpeg", i];
        //    [self setImageToTarget:[UIImage imageNamed:filename]];
        
        
        //self.setImageToTarget(self.resArr[i - 1])
        //self.imageView.backgroundColor = UIColor.whiteColor()
        //self.resultImageView.image = nil
//        self.imageView.image = nil
        
//        self.imageView.image = self.origArr[i - 1]
//        self.imageView.alpha = 0.2
//        self.touchDrawView.clearForReal()
//        self.imageView.backgroundColor = UIColor.clearColor()
//        self.resultImageView.image = self.resArr[i - 1]
        
//        self.resultImageView.image = self.origArr[i - 1]
//        self.resultImageView.alpha = 1.0
//        self.imageView.image = self.resArr[i - 1]
//        self.imageView.alpha = 1.0
//        self.imageView.backgroundColor = UIColor.whiteColor()
//        self.imageView.image = masking(self.origArr[i - 1], mask: self.resArr[i - 1])
        
        self.imageView.image = self.origArr[i - 1]
        self.resultImageView.image = self.resArr[i - 1]
        self.imageView.alpha = 0.2
    }
    
    func testUsingImage(image: UIImage) {
        
        self.tapOnReset("nil")
        
        self.setImageToTarget(image)
        
        self.imagePicker?.dismissViewControllerAnimated(true, completion: nil)
        self.imagePicker = nil
        
        
        //    self.grabRect = [self getTouchedRectWithImageSize:self.resizedImage.size];
        
        //    self.grabRect = [self.view frame];
        //    [self doGrabcut];
        //    self.touchState = TouchStateRect;
        self.tapOnRect("nil")
        
        if (!CGRectIsNull(self.grabRect) && !CGRectIsEmpty(self.grabRect)) {
            self.tapOnMinus("nil")
//            self.hasSpecifiedLabels = true
            NSLog("processing...s");
            //        [self doGrabcut];
            self.tapOnDoGrabcut("nil")
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
        let state: String = "Touch State : ";
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
        let minX: CGFloat = startPoint.x > endPoint.x ? endPoint.x*widthScale : startPoint.x*widthScale;
        let maxX: CGFloat = startPoint.x < endPoint.x ? endPoint.x*widthScale : startPoint.x*widthScale;
        let minY: CGFloat = startPoint.y > endPoint.y ? endPoint.y*heightScale : startPoint.y*heightScale;
        let maxY: CGFloat = startPoint.y < endPoint.y ? endPoint.y*heightScale : startPoint.y*heightScale;
        
        return CGRectMake(minX, minY, maxX - minX, maxY - minY)
    }
    
    func doGrabcut() {
        self.showLoadingIndicatorView()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var resultImage: UIImage! = self.grabcut.doGrabCut(self.resizedImage, foregroundBound: self.grabRect, iterationCount: 5)
            resultImage = masking(self.originalImage, mask: resizeImage(resultImage, size: self.originalImage.size))
            
            dispatch_async(dispatch_get_main_queue(), {
                self.resultImageView.image = resultImage
//                self.imageView.image = resultImage
//                self.resultImageView.alpha = 1
//                self.resultImageView.setNeedsDisplay()
//                self.touchDrawView.clearForReal()
//                self.touchDrawView.hidden = true
//                self.imageView.hidden = true
//                self.resultImageView.hidden = true
//                UIImageWriteToSavedPhotosAlbum(self.imageView.image!, nil, nil, nil)
//                UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, nil)
                self.imageView.alpha = 0.2
//                self.imageView.alpha = 1.0
                self.resultImageView.backgroundColor = UIColor.redColor()
//                self.resultImageView.backgroundColor = UIColor.blackColor()
//                self.resultImageView.alpha = 1.0
                
                self.hideLoadingIndicatorView()
            })
        })
    }
    
    func doGrabcutWithMaskImage(image: UIImage) {
        self.showLoadingIndicatorView()
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let sourceImage = self.resizedImage
            let maskImage = resizeImage(image, size: self.resizedImage.size)
            
            var resultImage: UIImage! = self.grabcut.doGrabCutWithMask(sourceImage, maskImage: maskImage, iterationCount: 5)
//            resultImage = masking(self.originalImage, mask: resizeImage(resultImage, size: self.originalImage.size))
            dispatch_async(dispatch_get_main_queue(), {
                self.resultImageView.image = resultImage
                self.imageView.alpha = 0.2
                self.hideLoadingIndicatorView()
                
                
//                self.hasSpecifiedLabels = true
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
        
//        shouldPause = false;
        
        if self.touchState == .Rect {
            if self.isUnderMinimumRect() {
                let alert = UIAlertController(title: "Opps", message: "More bigger rect for operation", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                return;
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
            
//            hasSpecifiedLabels = true
            
            var touchedMask: UIImage! = self.touchDrawView.maskImageWithPainting()
            //self.imageView.image = touchedMask
            //self.imageView.backgroundColor = UIColor.redColor()
            //return
            
//            self.resultImageView.image = touchedMask
//            resizeImage(touchedMask, size: self.)
//            self.doGrabcutWithMaskImage(touchedMask)
            if sender as? String == "nil" {
                
                if cachedMaskImage == nil {
//                    let touchedMask2: UIImage! = processPixelsInImage(self.originalImage)
//                    touchedMask = combineMaskImages(touchedMask, maskImage2: touchedMask2)
                    if shouldIsolateGreen {
                        touchedMask = combineMaskImages(touchedMask, maskImage2: self.originalImage)
                    }
                    cachedMaskImage = touchedMask
//                    self.doGrabcutWithMaskImage(cachedMaskImage!)
                }
                
                print("321: success")
//                self.doGrabcutWithMaskImage(touchedMask)
                self.doGrabcutWithMaskImage(cachedMaskImage!)
                self.touchDrawView.clearForReal()
            }else {
                //self.
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
        self.originalImage = resizeWithRotation(image, size: image.size)
        self.resizedImage = self.getProperResizedImage(self.originalImage)
        self.imageView.image = self.originalImage
        self.initStates()
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
        //    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        self.imagePicker?.mediaTypes = [kUTTypeImage as String]
        
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        self.imagePicker?.allowsEditing = false
        
        self.imagePicker?.delegate = delegate;
        
        controller?.presentViewController(self.imagePicker!, animated: true, completion: nil)
        return true
    }
    
//    func startMediaBrowserFromViewController<T: AnyObject where T: UIImagePickerControllerDelegate>(controller: UIViewController, usingDelegate delegate: T) {
    func startMediaBrowserFromViewController(controller: UIViewController?, usingDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>?) -> Bool {
        
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) == false || delegate == nil || controller == nil {
            return false
        }
        
        self.imagePicker = UIImagePickerController()
        //    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        self.imagePicker?.sourceType = .PhotoLibrary;
        
        // Displays saved pictures and movies, if both are available, from the
        // Camera Roll album.
        self.imagePicker?.mediaTypes = [kUTTypeImage as String]
        //    [UIImagePickerController availableMediaTypesForSourceType:
        //     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        self.imagePicker?.allowsEditing = false
        
        self.imagePicker?.delegate = delegate
        
        controller?.presentViewController(self.imagePicker!, animated: true, completion: nil)
        return true
    }
    
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
        
        self.tapOnReset("nil")
        
        let taskBlock = {
            self.setImageToTarget(resultImage)
            
            self.imagePicker?.dismissViewControllerAnimated(true, completion: nil)
            self.imagePicker = nil
        }
        
        if resizedImage != nil {
//            print("passed test 4567382")
            print("passed test 4567382: \(self.originalImage.size)  ||  \(resultImage.size)")
            
            if self.originalImage.size != resultImage.size {
                print("passed test gfdsa: \(self.originalImage.size)  ||  \(resultImage.size)")
                taskBlock()
                return
            }
        }
        
        taskBlock()
        
        
        //    _grabRect = [self getTouchedRectWithImageSize:_resizedImage.size];
        
        //    _grabRect = [self.view frame];
        //    [self doGrabcut];
        //    _touchState = TouchStateRect;
        self.tapOnRect("nil")
        
        
        if (!CGRectIsNull(self.grabRect) && !CGRectIsEmpty(self.grabRect)) {
//            self.touchState = .Minus // .Plus Or .Minus, either-or
            self.tapOnMinus("nil")
            NSLog("processing...s");
            //        [self doGrabcut];
            self.tapOnDoGrabcut("nil")
        }
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
        spinner.frame = CGRectSetOrigin(spinner.frame, CGPointMake(floor(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(spinner.bounds)), floor(CGRectGetMidY(self.view.bounds) - CGRectGetMidY(spinner.bounds))));
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
