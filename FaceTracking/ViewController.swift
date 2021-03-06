//
//  ViewController.swift



import UIKit
import AVFoundation
import Spring
import CoreImage


@available(iOS 10.0, *)
protocol photoManagementDelegate: class {

    func managerWillPushWith(_ manager: ViewController, Data: [Photo] )

}

@available(iOS 10.0, *)
class ViewController: UIViewController {

    weak var delegate: photoManagementDelegate?

    var photoArray: [Photo] = []

    let objects = Objects()

    var session: AVCaptureSession?
    var stillOutput = AVCaptureStillImageOutput()
    var borderLayer: CAShapeLayer?
    var sensitive: Float = 20.0
    var sensitivity = 40
    
    var progress: Float = 0 {
        
        didSet {
            print (oldValue)
            if oldValue >= 1 {
                snap()
            }
        }
    }

    var sensitivityCount: Int = 0 {
        willSet {
           print (newValue)
        }
        didSet {
            add(sensitivity: sensitivity)
        }
    }
    
    var captureImageView: UIImageView = UIImageView()


    @IBOutlet weak var blur: UIVisualEffectView! = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blr = UIVisualEffectView(effect: blurEffect)
        return blr
    }()
    
    @IBOutlet weak var optionView: SpringView!
    
    @IBOutlet weak var slow: SpringButton!
    
    @IBOutlet weak var normal: SpringButton!
    
    @IBOutlet weak var fast: SpringButton!
    
    @IBOutlet weak var cancel: UIButton!
    
    let detailsView: DetailsView = {
        let detailsView = DetailsView()
        detailsView.setup()
        
        return detailsView
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
        var previewLay = AVCaptureVideoPreviewLayer(session: self.session!)
        previewLay?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        return previewLay
    }()
    
    lazy var frontCamera: AVCaptureDevice? = {
        guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] else { return nil }
        
        return devices.filter { $0.position == .front }.first
    }()
    
    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow])



    let imageView = UIImageView(frame: CGRect(x: -50, y: -50, width: 667 - 150, height: 375))

    var isFiltered: Bool = false




    // Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        captureImageView.isUserInteractionEnabled = true



        optionView.isHidden = true

        blur.isHidden = true

        sessionPrepare()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = CGRect(x: 0, y: 75, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 150 )
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        print("========== VIEWWILLAPPEAR ==========")

        self.navigationController?.navigationBar.isHidden = true

        session?.startRunning()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let previewLayer = previewLayer else { return }
       
        view.layer.addSublayer(previewLayer)
        view.addSubview(detailsView)


        view.addSubview(imageView)

        imageView.transform = CGAffineTransform(rotationAngle: (.pi / 2))


        view.bringSubview(toFront: detailsView)
        setUpObjects()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("========== VIEWWILL DISAPPEAR ==========")

        session?.stopRunning()

    }

    
    func setUpObjects() {

        slow.setTitle("SLOW", for: .normal)
        slow.addTarget(self, action: #selector(changeToSlow), for: .touchUpInside)
        
        normal.setTitle("NORMAL", for: .normal)
        normal.addTarget(self, action: #selector(changeToNormal), for: .touchUpInside)
        
        fast.setTitle("FAST", for: .normal)
        fast.addTarget(self, action: #selector(changeToFast), for: .touchUpInside)


        cancel.setTitle("Cancel", for: .normal)
        cancel.backgroundColor = .red
        cancel.tintColor = .white
        cancel.addTarget(self, action: #selector(dismissSensitivitySelection), for: .touchUpInside)

        objects.sensitivityBtn.addTarget(self, action: #selector(changeSensitivity), for: .touchUpInside)
        
        objects.upperBackground.addSubview(objects.sensitivityBtn)
        objects.upperBackground.addSubview(objects.progressView)
        objects.upperBackground.addSubview(objects.sensitivityLabel)

        captureImageView.backgroundColor = .clear
        captureImageView.contentMode = .scaleAspectFill
        captureImageView.frame = CGRect(x: UIScreen.main.bounds.width - 40, y: 0, width: 40, height: 75)

        let tapOnImage = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        captureImageView.addGestureRecognizer(tapOnImage)



        objects.snapIcon.addTarget(self, action: #selector(snap), for: .touchUpInside)
        
        objects.lowerBackground.addSubview(captureImageView)
        objects.lowerBackground.addSubview(objects.snapIcon)

        view.addSubview(objects.upperBackground)
        view.addSubview(objects.lowerBackground)


        view.bringSubview(toFront: objects.upperBackground)
        view.bringSubview(toFront: objects.lowerBackground)
        view.bringSubview(toFront: blur)
        view.bringSubview(toFront: optionView)


        objects.setLowerBackgroundConstraints()
        objects.setUpperBackgroundConstraints()
        
    }

    func handleTap () {

        print ("tapped")

        guard let vc  = self.storyboard?.instantiateViewController(withIdentifier: "PhotoGridCollectionViewController") as? PhotoGridCollectionViewController else { return }

//        DispatchQueue.main.async{
//            self.delegate?.managerWillPushWith(self, Data: self.photoArray)
//        }

        vc.photoArray = self.photoArray

        self.navigationController?.pushViewController(vc, animated: true)

    }
}



@available(iOS 10.0, *)
extension ViewController {
    
    func sessionPrepare() {
        session = AVCaptureSession()
       
        guard let session = session, let captureDevice = frontCamera else { return }
        
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            session.beginConfiguration()
            
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            let output = AVCaptureVideoDataOutput()

            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]

            output.alwaysDiscardsLateVideoFrames = true

            stillOutput = AVCaptureStillImageOutput()
            stillOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if session.canAddOutput(stillOutput) {
                session.addOutput(stillOutput)

            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
                
            }
            
            session.commitConfiguration()
            
            let queue = DispatchQueue(label: "output.queue")
            output.setSampleBufferDelegate(self, queue: queue)
            
        } catch {

            print("error with creating AVCaptureDeviceInput")

        }
    }


    func update(with faceRect: CGRect, text: String) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.detailsView.detailsLabel.text = text
                self.detailsView.alpha = 1.0
                self.detailsView.frame = faceRect
            }
        }
    }
    
}




@available(iOS 10.0, *)
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        

        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)

        let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as! [String : Any]?)

        let options: [String : Any] = [CIDetectorImageOrientation: exifOrientation(orientation: UIDevice.current.orientation),
                                       CIDetectorSmile: true,
                                       CIDetectorEyeBlink: true]


        if isFiltered {

            // TESTING
            let filter = CIFilter(name: "CIComicEffect")

            filter!.setValue(ciImage, forKey: kCIInputImageKey)
            let filteredImage = UIImage(ciImage: filter!.value(forKey: kCIOutputImageKey) as! CIImage!)


            DispatchQueue.main.async
                {
                    self.imageView.image = filteredImage

            }

        }





        let allFeatures = faceDetector?.features(in: ciImage, options: options)
    
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(formatDescription!, false)

        guard let features = allFeatures else { return }
        
        for feature in features {
            if let faceFeature = feature as? CIFaceFeature {
                let faceRect = calculateFaceRect(facePosition: faceFeature.mouthPosition, faceBounds: faceFeature.bounds, clearAperture: cleanAperture)
                let featureDetails = ["has smile: \(faceFeature.hasSmile)",
                    "has closed left eye: \(faceFeature.leftEyeClosed)",
                    "has closed right eye: \(faceFeature.rightEyeClosed)"]
                
                update(with: faceRect, text: featureDetails.joined(separator: "\n"))
                
                if faceFeature.hasSmile {

                    
                    countProgress(sensitive: sensitive)
                    
                    
                } else {
                    
                    DispatchQueue.main.async {
                        
                       self.objects.progressView.progress = 0
                    
                    }
                    

                }
            }
 
        }
        
        if features.count == 0 {
            DispatchQueue.main.async {
                self.detailsView.alpha = 0.0
            }
        }
        
    }
    
    
    func snap() {
        if let videoConnection = stillOutput.connection(withMediaType: AVMediaTypeVideo) {
            
            print ("yay")
            
            
            stillOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData! as CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    self.captureImageView.image = image

                    let imageToAppend = Photo(photoImage: image)

                    self.photoArray.append(imageToAppend)


                    //Commeneted for now
//                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    
                }
            })

        } else {
            print ("FAIL!!!!!")
        }

        //TEST
        if isFiltered {
            isFiltered = false
            self.imageView.removeFromSuperview()

        } else {
            isFiltered = true
            self.view.addSubview(imageView)
        }

    }



    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
//            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
            
            print ("successfully saved photo into photo library")
        }
    }


    func plusOne() {

        objects.progressView.progress += 1 / 20
        
        if objects.progressView.progress >= 1 {
            snap()
            objects.progressView.progress = 0
        }
    }
    
    func countProgress(sensitive: Float) {
        
        DispatchQueue.main.async {
            self.objects.progressView.progress += 1 / sensitive
            
            if self.objects.progressView.progress >= 1 {
                
                self.snap()
                
                self.objects.progressView.progress = 0
            }
        }
        
        print("=========================", objects.progressView.progress)

    }


    func add(sensitivity: Int) {
        
        if sensitivityCount < sensitivity {
            print ("NOT YET")
        } else if sensitivityCount == sensitivity {
            
            snap()
            sensitivityCount = 0
        }
        
        
    }
    
    func changeSensitivity() {
        
        optionView.isHidden = false
        blur.isHidden = false
        blur.alpha = 0.0
        
        UIView.animate(withDuration: 0.5) {
            self.blur.alpha = 1.0
        }
        
        
        optionView.animation = "fadeInDown"
        optionView.curve = "linear"
        optionView.force = 2.0
        optionView.duration = 1.0
        optionView.damping = 0.8
        optionView.animate()
        
    }
    
    
    func dismissSensitivitySelection() {
        
        UIView.animate(withDuration: 0.5) {
            self.blur.alpha = 0.0
        }
        
        optionView.animation = "fadeOut"
        optionView.force = 2.0
        optionView.duration = 1.0
        optionView.damping = 0.8
        optionView.animate()
    }
    
    func changeToSlow() {
        self.sensitive = 20.0
        objects.sensitivityLabel.text = "SLOW"
        slow.animation = "morph"
        slow.curve = "linear"
        slow.duration = 0.5
        slow.damping = 0.8
        slow.velocity = 0.6
        slow.animate()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5 ) {
            self.dismissSensitivitySelection()
        }
    }
    
    func changeToNormal() {
        
        self.sensitive = 10.0
        objects.sensitivityLabel.text = "NORMAL"
        normal.animation = "morph"
        normal.curve = "linear"
        normal.duration = 0.5
        normal.damping = 0.8
        normal.velocity = 0.6
        normal.animate()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5 ) {
            self.dismissSensitivitySelection()
        }

    }
    
    func changeToFast(){
        
        self.sensitive = 5.0
        objects.sensitivityLabel.text = "FAST"
        fast.animation = "morph"
        fast.curve = "linear"
        fast.duration = 0.5
        fast.damping = 0.8
        fast.velocity = 0.6
        fast.animate()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5 ) {
            self.dismissSensitivitySelection()
        }
    }
    
    func exifOrientation(orientation: UIDeviceOrientation) -> Int {
        switch orientation {
        case .portraitUpsideDown:
            return 8
        case .landscapeLeft:
            return 3
        case .landscapeRight:
            return 1
        default:
            return 6
        }
    }
    
    func videoBox(frameSize: CGSize, apertureSize: CGSize) -> CGRect {
        let apertureRatio = apertureSize.height / apertureSize.width
        let viewRatio = frameSize.width / frameSize.height
        
        var size = CGSize.zero
     
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width
            size.height = apertureSize.width * (frameSize.width / apertureSize.height)
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width)
            size.height = frameSize.height
        }
        
        var videoBox = CGRect(origin: .zero, size: size)
       
        if (size.width < frameSize.width) {
            videoBox.origin.x = (frameSize.width - size.width) / 2.0
        } else {
            videoBox.origin.x = (size.width - frameSize.width) / 2.0
        }
        
        if (size.height < frameSize.height) {
            videoBox.origin.y = (frameSize.height - size.height) / 2.0
        } else {
            videoBox.origin.y = (size.height - frameSize.height) / 2.0
        }
       
        return videoBox
    }

    func calculateFaceRect(facePosition: CGPoint, faceBounds: CGRect, clearAperture: CGRect) -> CGRect {
        let parentFrameSize = previewLayer!.frame.size
        let previewBox = videoBox(frameSize: parentFrameSize, apertureSize: clearAperture.size)
        
        var faceRect = faceBounds
        
        swap(&faceRect.size.width, &faceRect.size.height)
        swap(&faceRect.origin.x, &faceRect.origin.y)

        let widthScaleBy = previewBox.size.width / clearAperture.size.height
        let heightScaleBy = previewBox.size.height / clearAperture.size.width
        
        faceRect.size.width *= widthScaleBy
        faceRect.size.height *= heightScaleBy
        faceRect.origin.x *= widthScaleBy
        faceRect.origin.y *= heightScaleBy
        
        faceRect = faceRect.offsetBy(dx: 0.0, dy: previewBox.origin.y)
        let frame = CGRect(x: parentFrameSize.width - faceRect.origin.x - faceRect.size.width / 2.0 - previewBox.origin.x / 2.0, y: faceRect.origin.y, width: faceRect.width, height: faceRect.height)
        
        return frame
    }
}


