//
//  ViewController.swift
//  FIT1041 GrabCut
//
//  Created by Jason @ Monash on 22/09/2016.
//  Copyright © 2016 Jason Pan. All rights reserved.
//

import UIKit
import MobileCoreServices

//static inline double radians (double degrees) {return degrees * M_PI/180;}
//const static int MAX_IMAGE_LENGTH = 450;
extension Int {
//    var degreesToRadians: Double { return Double(self) * M_PI / 180 }
//    var radiansToDegrees: Double { return Double(self) * 180 / M_PI }
    var radians: Double { return Double(self) * M_PI / 180 }
    var degrees: Double { return Double(self) * 180 / M_PI }
}

protocol DoubleConvertible {
    init(_ double: Double)
    var double: Double { get }
}
extension Double : DoubleConvertible { var double: Double { return self         } }
extension Float  : DoubleConvertible { var double: Double { return Double(self) } }
extension CGFloat: DoubleConvertible { var double: Double { return Double(self) } }

extension DoubleConvertible {
    var degreesToRadians: DoubleConvertible {
        return Self(double * M_PI / 180)
    }
    var radiansToDegrees: DoubleConvertible {
        return Self(double * 180 / M_PI)
    }
}

func radians(degrees: Double) -> Double { return degrees * M_PI/180 }
func radians(degrees: Int) -> Int { return Int(radians(Double(degrees))) }
func radians(degrees: CGFloat) -> CGFloat { return CGFloat(radians(Double(degrees))) }
let MAX_IMAGE_LENGTH: CGFloat = 450

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
//    weak var touchState: TouchState!
//    weak var grabRect: CGRect!
    var originalImage: UIImage!
    var resizedImage: UIImage!
    var imagePicker: UIImagePickerController?
    
    var spinner: UIActivityIndicatorView!
    var dimmedView: UIView!
    
    var i: Int = 1
    var timer0: NSTimer?
    var timer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.grabcut = GrabCutManager()
        
        self.originalImage = UIImage(named: "test.jpg")
        self.resizedImage = self.getProperResizedImage(self.originalImage)
        
        self.initStates()
        
        //    [self testUsingImage:[UIImage imageNamed:@"test1.jpeg"]];
        let filename = "test\(i).jpeg"
        self.testUsingImage(UIImage(named: filename)!)
        
        
        //    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(test1) userInfo:nil repeats:true];
        
        //    timer0 = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(test1) userInfo:nil repeats:true];

        if resArr == nil {
            resArr = []
            
            //        [timer invalidate];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                for i in 0 ..< 3 {
                    
                    
                    while (self.resultImageView.image == nil) {}
                    self.timer0?.invalidate()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.resultImageView.image = nil
                    })
                    
                    let filename = "test\(i+1).jpeg"
                    self.testUsingImage(UIImage(named: filename)!)
                    
                    while (self.resultImageView.image == nil) {}
                    
                    self.timer0?.invalidate()
                    
                    self.resArr.append(self.resultImageView.image!)
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
    
    var shouldPause: Bool = false
//    var resArr: NSMutableArray!
    var resArr: [UIImage]!
    
    func test1() {
        
        if (shouldPause) {
            return;
        }
        
        i += 1;
        
        if (i > 3) {
            i = 1;
        }
        
        //    [self tapOnReset:nil];
        let filename = "test\(i).jpeg"
        //    [self setImageToTarget:[UIImage imageNamed:filename]];
        self.testUsingImage(UIImage(named: filename)!)
    }
    
    func test() {
        
        let cond: Bool = !CGRectIsNull(self.grabRect) && !CGRectIsEmpty(self.grabRect);
        
        if (shouldPause || !cond) {
            
            //        //    [self tapOnReset:nil];
            //        NSString *filename = [NSString stringWithFormat:@"test%i.jpeg", i];
            //        //    [self setImageToTarget:[UIImage imageNamed:filename]];
            //        [self testUsingImage:[UIImage imageNamed:filename]];
            
            return;
        }
        
        timer0?.invalidate()
        
        i += 1;
        
        if (i > 3) {
            i = 1;
        }
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
        self.setImageToTarget(self.resArr[i - 1])
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
                return self.resizeWithRotation(original, size: CGSizeMake(MAX_IMAGE_LENGTH, MAX_IMAGE_LENGTH/ratio))
            }
        }else {
            if original.size.height > MAX_IMAGE_LENGTH {
                return self.resizeWithRotation(original, size: CGSizeMake(MAX_IMAGE_LENGTH*ratio, MAX_IMAGE_LENGTH))
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
        default:
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
    
//    -(void) doGrabcut{
//    [self showLoadingIndicatorView];
//
//    __weak typeof(self)weakSelf = self;
//    }
    
    func doGrabcut() {
        self.showLoadingIndicatorView()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var resultImage: UIImage! = self.grabcut.doGrabCut(self.resizedImage, foregroundBound: self.grabRect, iterationCount: 5)
            resultImage = self.masking(self.originalImage, mask: self.resizeImage(resultImage, size: self.originalImage.size))
            
            dispatch_async(dispatch_get_main_queue(), {
                self.resultImageView.image = resultImage
                self.imageView.alpha = 0.2
                
                self.hideLoadingIndicatorView()
            })
        })
    }
    
//    -(void) doGrabcutWithMaskImage:(UIImage*)image{
//    [self showLoadingIndicatorView];
//    
//    __weak typeof(self)weakSelf = self;
//    }
    
    func doGrabcutWithMaskImage(image: UIImage) {
        self.showLoadingIndicatorView()
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var resultImage: UIImage! = self.grabcut.doGrabCutWithMask(self.resizedImage, maskImage: self.resizeImage(image, size:self.resizedImage.size), iterationCount:5)
            resultImage = self.masking(self.originalImage, mask: self.resizeImage(resultImage, size: self.originalImage.size))
            dispatch_async(dispatch_get_main_queue(), {
                self.resultImageView.image = resultImage
                self.imageView.alpha = 0.2
                self.hideLoadingIndicatorView()
            })
        })
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSLog("began")
        
        shouldPause = true
        
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
        
        self.touchDrawView.clear()
        self.grabcut.resetManager()
    }
    
    @IBAction func tapOnRect(sender: AnyObject) {
        self.touchState = .Rect
        self.updateStateLabel()
        
        self.plusButton.enabled = false
        self.minusButton.enabled = false
        self.doGrabcutButton.enabled = true
    }
    
    @IBAction func tapOnPlus(sender: AnyObject) {
        self.touchState = .Plus
        self.updateStateLabel()
        
        self.touchDrawView.setCurrentState(.Plus)
    }
    
    @IBAction func tapOnMinus(sender: AnyObject) {
        self.touchState = .Minus
        self.updateStateLabel()
        
        self.touchDrawView.setCurrentState(.Minus)
    }
    
    @IBAction func tapOnDoGrabcut(sender: AnyObject) {
        
        shouldPause = false;
        
        if self.touchState == .Rect {
            if self.isUnderMinimumRect() {
                let alert = UIAlertController(title: "Opps", message: "More bigger rect for operation", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                return;
            }
            
            self.doGrabcut()
            self.touchDrawView.clear()
            
            self.rectButton.enabled = false
            self.plusButton.enabled = true
            self.minusButton.enabled = true
            self.doGrabcutButton.enabled = false
        }else if self.touchState == .Plus || self.touchState == .Minus {
            let touchedMask: UIImage! = self.touchDrawView.maskImageWithPainting()
            self.doGrabcutWithMaskImage(touchedMask)
            
            self.touchDrawView.clear()
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
        timer.invalidate()
    }
    
    @IBAction func tapOnCamera(sender: AnyObject) {
        self.startCameraControllerFromViewController(self, usingDelegate: self)
        timer.invalidate()
    }
    
    func setImageToTarget(image: UIImage) {
        self.originalImage = self.resizeWithRotation(image, size: image.size)
        self.resizedImage = self.getProperResizedImage(self.originalImage)
        self.imageView.image = self.originalImage
        self.initStates()
        self.grabcut.resetManager()
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
        
        self.setImageToTarget(resultImage)
        
        self.imagePicker?.dismissViewControllerAnimated(true, completion: nil)
        self.imagePicker = nil
        
        
        //    _grabRect = [self getTouchedRectWithImageSize:_resizedImage.size];
        
        //    _grabRect = [self.view frame];
        //    [self doGrabcut];
        //    _touchState = TouchStateRect;
        self.tapOnRect("nil")
        
        if (!CGRectIsNull(self.grabRect) && !CGRectIsEmpty(self.grabRect)) {
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
        self.dimmedView.backgroundColor = UIColor.init(red:0, green:0, blue:0, alpha:0.7)
        self.view.addSubview(self.dimmedView)
        
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: activityIndicatorViewStyle)
        spinner.frame = CGRectSetOrigin(spinner.frame, CGPointMake(floor(CGRectGetMidX(self.view.bounds) - CGRectGetMidX(spinner.bounds)), floor(CGRectGetMidY(self.view.bounds) - CGRectGetMidY(spinner.bounds))));
        spinner.autoresizingMask = [.FlexibleLeftMargin,.FlexibleRightMargin,.FlexibleTopMargin,.FlexibleBottomMargin]
        spinner.startAnimating()
        self.view.addSubview(spinner)
        self.spinner = spinner
        
        self.view.userInteractionEnabled = false
    }
    
    func hideLoadingIndicatorView() {
        self.spinner.stopAnimating()
        self.spinner.removeFromSuperview()
        self.spinner = nil
        
        self.dimmedView.removeFromSuperview()
        self.dimmedView = nil
        
        self.view.userInteractionEnabled = true
    }
    
}
