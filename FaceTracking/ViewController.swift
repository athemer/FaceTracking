//
//  ViewController.swift
//  AutoCamera


import UIKit
import AVFoundation

class DetailsView: UIView {

    lazy var detailsLabel: UILabel = {
        let detailsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        detailsLabel.numberOfLines = 0
        detailsLabel.textColor = .white
        detailsLabel.font = UIFont.systemFont(ofSize: 18.0)
        detailsLabel.textAlignment = .left
       
        return detailsLabel
    }()
    
    func setup() {
        layer.borderColor = UIColor.red.withAlphaComponent(0.7).cgColor
        layer.borderWidth = 5.0
  
        addSubview(detailsLabel)
    }
    
   override var frame: CGRect {
        didSet(newFrame) {
            var detailsFrame = detailsLabel.frame
            detailsFrame = CGRect(x: 0, y: newFrame.size.height, width: newFrame.size.width * 2.0, height: newFrame.size.height / 2.0)
            detailsLabel.frame = detailsFrame
        }
    }
}


@available(iOS 10.0, *)
class ViewController: UIViewController {

    
    let objects = Objects()
    
    var session: AVCaptureSession?
    var stillOutput = AVCaptureStillImageOutput()
    var borderLayer: CAShapeLayer?
   
    
    var sensitivity = 40
    
    var sensitivityCount: Int = 0 {
        willSet {
           print (newValue)
        }
        didSet {
            add(sensitivity: sensitivity)
        }
    }
    
    var captureImageView: UIImageView = UIImageView()
//    @IBOutlet weak var captureImageView: UIImageView!
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = CGRect(x: 0, y: 100, width: 375, height: 467)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let previewLayer = previewLayer else { return }
        
        let viewToAdd = UIView(frame: CGRect(x: 0, y: 567, width: 375, height: 100))
        viewToAdd.backgroundColor = .red
        let view2 = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 50))
        view2.backgroundColor = .green
        
        let btn = UIButton()
        btn.setTitle("SNAP!!!", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        btn.backgroundColor = .yellow
        btn.tintColor = .blue
        btn.addTarget(self, action: #selector(snap), for: .touchUpInside)
    
        
        
        let btn2 = UIButton()
        btn2.setTitle("+1", for: .normal)
        btn2.frame = CGRect(x: 100, y: 0, width: 100, height: 50)
        btn2.backgroundColor = .white
        btn2.tintColor = .red
        btn2.addTarget(self, action: #selector(plusOne), for: .touchUpInside)
        
        
        captureImageView.image = UIImage(named: "sample")
        captureImageView.contentMode = .scaleAspectFill
        captureImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        viewToAdd.addSubview(btn)
        viewToAdd.addSubview(btn2)
        
        view.layer.addSublayer(previewLayer)
        view.addSubview(detailsView)
        view.addSubview(viewToAdd)
        view.addSubview(captureImageView)
        setUpObjects()
        view.bringSubview(toFront: detailsView)
        view.bringSubview(toFront: viewToAdd)
        view.bringSubview(toFront: captureImageView)

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionPrepare()
        
        session?.startRunning()
    }
    
    func setUpObjects() {
        
        objects.progressView.progress = 0 
        
        objects.upperBackground.addSubview(objects.sensitivityBtn)
        objects.upperBackground.addSubview(objects.progressView)

        
        

        view.addSubview(objects.upperBackground)
        view.bringSubview(toFront: objects.upperBackground)

        
        
        
        
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
                    
                    print ("smiled")
                    
//                    snap()
                    plusOne()
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
                    

                }
            })

        } else {
            print ("FAIL!!!!!")
        }

    }
    
    func plusOne() {
        
        sensitivityCount += 1
        
    }
    
    
    func add(sensitivity: Int) {
        
        if sensitivityCount < sensitivity {
            print ("NOT YET")
        } else if sensitivityCount == sensitivity {
            
            snap()
            sensitivityCount = 0
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

@available(iOS 10.0, *)
extension ViewController {
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
