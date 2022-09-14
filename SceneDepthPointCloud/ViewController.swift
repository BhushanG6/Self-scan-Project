/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import Combine
import Metal
import MetalKit
import RealityKit
import simd
import SwiftUI
import UIKit
import AVFoundation
import VideoToolbox
import CoreVideo
var output: PoseNetOutput?
var configuration: PoseBuilderConfiguration?

var angArray=[0:true,30:true,60:true,90:true,120:true,150:true,180:true,210:true,240:true,270:true,300:true,330:true,360:true]
var bvalue=true
var r:Double=0
var ang:Double?
var theta:Double=0
var disp:Double=0
var eventfront=true
var eventleft=false
var mid:simd_float3=[0.0,0.0,0.0]
var firstb=false
var leftshld1:simd_float3=[0.0,0.0,0.0]
var rightshld1:simd_float3=[0.0,0.0,0.0]

var leftshld2:simd_float3=[0.0,0.0,0.0]
var rightshld2:simd_float3=[0.0,0.0,0.0]
var leftarm:simd_float2=[0.0,0.0]
var rightarm:simd_float2=[0.0,0.0]
final class ViewController: UIViewController, ARSessionDelegate{
    private let isUIEnabled = true
    private let confidenceControl = UISegmentedControl(items: ["Low", "Medium", "High"])
    private let rgbRadiusSlider = UISlider()
    let modelInputSize = CGSize(width: 513, height: 513)
    private var currentFrame: CGImage?
    let model = MobileOpenPose()

    private let session = ARSession()
    @IBOutlet weak var saveButton: UIButton!
    private var renderer: Renderer!
    // MARK: - Properties
    var trackingStatus: String = ""

    var start = true
    private var poseNet: PoseNet!
    private var poseBuilderConfiguration = PoseBuilderConfiguration()

    func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait two seconds to simulate some work happening
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            // then remove the spinner view controller
//            child.willMove(toParent: nil)
//            child.view.removeFromSuperview()
//            child.removeFromParent()
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        session.delegate = self
        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }

        poseNet.delegate = self
        print("MyD",device.makeDefaultLibrary())
        // Set the view to use the default device
        if let view = view as? MTKView {
            view.device = device
            
            view.backgroundColor = UIColor.clear
            // we need this to enable depth test
            view.depthStencilPixelFormat = .depth32Float
            view.contentScaleFactor = 1
            view.delegate = self
            print("Entered into renderer")
            // Configure the renderer to draw to the view
            renderer = Renderer(session: session, metalDevice: device, renderDestination: view)
            renderer.drawRectResized(size: view.bounds.size)
        }
        renderer.fireTimer()
        renderer.createderectory()
        
        /*
        // Confidence control
        confidenceControl.backgroundColor = .white
        confidenceControl.selectedSegmentIndex = renderer.confidenceThreshold
        confidenceControl.addTarget(self, action: #selector(viewValueChanged), for: .valueChanged)
        
        // RGB Radius control
        rgbRadiusSlider.minimumValue = 0
        rgbRadiusSlider.maximumValue = 1.5
        rgbRadiusSlider.isContinuous = true
        rgbRadiusSlider.value = renderer.rgbRadius
        rgbRadiusSlider.addTarget(self, action: #selector(viewValueChanged), for: .valueChanged)
        
        let stackView = UIStackView(arrangedSubviews: [confidenceControl, rgbRadiusSlider])
        stackView.isHidden = !isUIEnabled
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a world-tracking configuration, and
        // enable the scene depth frame-semantic.
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = .sceneDepth

        // Run the view's session
        session.run(configuration)
        
        // The screen shouldn't dim during AR experiences.
        UIApplication.shared.isIdleTimerDisabled = true
    }
  
    @IBAction func saveButtonAction(_ sender: Any) {
        print("save action")
        DispatchQueue.main.async {
//            self.renderer.changeoriginnew()
           self.renderer.savePointsToFilenew()
//            self.renderer.particleBufferIn()
//            self.renderer.isSavingFile = true
           self.session.pause()
           
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = mainStoryBoard.instantiateViewController(withIdentifier: "ShowPointCloudViewController") as! ShowPointCloudViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
            
        }

    }
    @objc
    private func viewValueChanged(view: UIView) {
        switch view {
            
        case confidenceControl:
            renderer.confidenceThreshold = confidenceControl.selectedSegmentIndex
            
        case rgbRadiusSlider:
            renderer.rgbRadius = rgbRadiusSlider.value
            
        default:
            break
        }
    }
    
    // Auto-hide the home indicator to maximize immersion in AR experiences.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Hide the status bar to maximize immersion in AR experiences.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

// MARK: - MTKViewDelegate

extension ViewController: MTKViewDelegate {
    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        //captureImage()
        if renderer.isCapture {
            print("draw")
        renderer.draw()
        } else {
            if renderer.isLoadingStarted {
                renderer.getFiles()
                createSpinnerView()
                renderer.isLoadingStarted = false
            }
        }
    }
        
}

// MARK: - RenderDestinationProvider

protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

extension MTKView: RenderDestinationProvider {
    
}

// MARK: - AR Session Management (ARSCNViewDelegate)

extension ViewController {
    
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      print("*** ARConfig: AR World Tracking Not Supported")
      return
    }
    
    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravity
    config.providesAudioData = false
    config.isLightEstimationEnabled = true
    config.environmentTexturing = .automatic
    session.run(config)
  }
  
  func resetARSession() {
    let config = session.configuration as!
      ARWorldTrackingConfiguration
    config.planeDetection = .horizontal
    session.run(config, options: [.resetTracking, .removeExistingAnchors])
  }
    func session(
        
        _ session: ARSession,

        didUpdate frame: ARFrame

     ) {

             print("get frame")

             

             //var results: [Pose]

             var images = session.currentFrame?.capturedImage

             

    //         let image1 = UIImage(ciImage: CIImage(cvPixelBuffer: images!))

             

    //         print("image",images,image1,image1.size.height,image1.size.width)

            // let image = VisionImage(image: image1)

             // Attempt to lock the image buffer to gain access to its memory.

    //         guard CVPixelBufferLockBaseAddress(images!, .readOnly) == kCVReturnSuccess

    //             else {

    //                 return

    //         }

    //         // Create Core Graphics image placeholder.

    //         var image: CGImage?

    //

    //         // Create a Core Graphics bitmap image from the pixel buffer.

    //         VTCreateCGImageFromCVPixelBuffer(images!, options: nil, imageOut: &image)

    //

    //         // Release the image buetectffer.

    //         CVPixelBufferUnlockBaseAddress(images!, .readOnly)

             // Get the CGImage on which to perform requests.

    //         guard let cgImage = image1.cgImage else { return }



             // Create a new image-request handler.

             guard let img_buff = images else{

                 print("no data caught")

                 return

             }
         guard CVPixelBufferLockBaseAddress(img_buff, .readOnly) == kCVReturnSuccess
             else {
                 return
         }

         // Create Core Graphics image placeholder.
         var image: CGImage?

         // Create a Core Graphics bitmap image from the pixel buffer.
         VTCreateCGImageFromCVPixelBuffer(img_buff, options: nil, imageOut: &image)

         // Release the image buffer.
         CVPixelBufferUnlockBaseAddress(img_buff, .readOnly)
         //currentFrame=image!
         
         poseNet.predict(image!)
         
    

         //poseNet.predict(image!)
         //let input = PoseNetInput(image: image, size: self.modelInputSize)
       
         
         //         print(img_buff)

//             let requestHandler = VNImageRequestHandler(cvPixelBuffer: img_buff)
//
//
//
//             // Create a new request to recognize a human body pose.
//
//             let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
//
//            print("request", request)
//
//
//
//             do {
//
//                 // Perform the body pose-detection request.
//
//                 try requestHandler.perform([request])
//
//             } catch {
//
//                 print("Unable to perform the request: \(error).")
//
//             }

             

            // visionImage.orientation = image.imageOrientation

    //         do {

    //             results = try poseDetector!.results(in: image)

    //         } catch let error {

    //           print("Failed to detect pose with error: \(error.localizedDescription).")

    //           return

    //         }

    //         guard let detectedPoses = results, !detectedPoses.isEmpty else {

    //           print("Pose detector returned no results.")

    //           return

    //         }

             

         }
    lazy var classificationRequest: [VNRequest] = {
        do {
            let model = try VNCoreMLModel(for: self.model.model)
            let classificationRequest = VNCoreMLRequest(model: model, completionHandler: self.handleClassification)
            return [ classificationRequest ]
        } catch {
            fatalError("Can't load Vision ML model: \(error)")
        }
    }()
    
    func handleClassification(request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNCoreMLFeatureValueObservation] else { fatalError() }
        let mlarray = observations[0].featureValue.multiArrayValue!
        let length = mlarray.count
        let doublePtr =  mlarray.dataPointer.bindMemory(to: Double.self, capacity: length)
        let doubleBuffer = UnsafeBufferPointer(start: doublePtr, count: length)
        let mm = Array(doubleBuffer)
        
        drawLine(mm)
    }
    
    func runCoreML(_ image: UIImage) {
      //  imageView.image = image
        
        let img = image.resize(to: CGSize(width: ImageWidth,height: ImageHeight)).cgImage!
        let classifierRequestHandler = VNImageRequestHandler(cgImage: img, options: [:])
        do {
            try classifierRequestHandler.perform(self.classificationRequest)
        } catch {
            print(error)
        }
    }
        func bodyPoseHandler(request: VNRequest, error: Error?) {

            guard let observations =

                    request.results as? [VNHumanBodyPoseObservation] else {

                return

            }

            

            // Process each observation to find the recognized body pose points.

            observations.forEach { processObservation($0) }

        }

        func processObservation(_ observation: VNHumanBodyPoseObservation) {

            

            // Retrieve all torso points.

            guard let recognizedPoints =

                    try? observation.recognizedPoints(.torso) else { return }

            

            // Torso joint names in a clockwise ordering.

            let torsoJointNames: [VNHumanBodyPoseObservation.JointName] = [
                .rightShoulder,
                .leftShoulder,
                
            ]


            // Retrieve the CGPoints containing the normalized X and Y coordinates.

            let imagePoints: [CGPoint] = torsoJointNames.compactMap {

                guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }

                

                // Translate the point from normalized-coordinates to image coordinates.

                return VNImagePointForNormalizedPoint(point.location,

                                                      1440,

                                                      1920)

            }
            //draw(points: imagePoints)

            print("Joints Captured",imagePoints.count)
            if imagePoints.count==2
            {
                leftarm = [Float(imagePoints[1].x),Float(imagePoints[1].y)]

            }
            if imagePoints.count==2
            {
                rightarm = [Float(imagePoints[0].x),Float(imagePoints[0].y)]

            }
            if eventfront {

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    leftshld1 = [Float(leftarm.x), Float(leftarm.y), 0.0]
                    rightshld1 = [Float(rightarm.x), Float(rightarm.y), 0.0]
                mid=(leftshld1+rightshld1)/2
               // print("turn")
//                print("-----------------------------------------------")
//                    print("Left Shoulder 1 is ", leftshld1)
//
//                    print("Right Shoulder 1 is ", rightshld1)

                                       
                    eventfront = false

                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                   
                    eventleft = true
                }
            }
            if eventleft {

               // DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                leftshld2 = [Float(leftarm.x), Float(leftarm.y), 0.0]
                rightshld2 = [Float(rightarm.x), Float(rightarm.y), 0.0]
            r = Double(self.distance3D(vector1: leftshld1, vector2: rightshld1))/2
            disp = Double(self.distance3D(vector1: leftshld1, vector2: leftshld2))
            var v1=leftshld1-mid
            var v2=leftshld2-mid
            //ang=asin(disp/(2*r))*2
            var m=sqrt(pow(v1.x,2)+pow(v1.y,2)+pow(v1.z,2))*(sqrt(pow(v2.x,2)+pow(v2.y,2)+pow(v2.z,2)))
            var dot1=dot(v1,v2)/m
            ang=acos(Double(dot1))
                var ang1=0.0
                if #available(iOS 15.0, *) {
                    var d1=Double(distance3D(vector1:leftshld2 , vector2:rightshld2))
                    if d1>2*r
                    {
                        d1=2*r-10
                    }
                    ang1 = acos(d1/(2*r))
                    print("angle detected", ang1  * (180/3.14159),(distance(leftshld1 , rightshld1)),(distance(leftshld2 , rightshld2)) )
                } else {
                    // Fallback on earlier versions
                    print("not detected angle")
                }
               
                    //theta = ang! * (180/3.14159)
//                    print("Radius is ", r)
         if abs(2*r-Double(self.distance3D(vector1: leftshld2, vector2: rightshld2)))<1 && !firstb
        {
             firstb=true
        }
        if abs(2*r-Double(self.distance3D(vector1: leftshld2, vector2: rightshld2)))<1 && firstb
        {
            print("Turned 360")
        }

            //theta=ang1
//              print("Displacement is ", disp)
//            var max=max()
            if theta < Double(85)
            {
                theta=ang1
            }
            else if theta > Double(85) && theta < Double(170)
            {
                theta=180-ang1
            }
            else if theta > 170 && theta > 260
            {
                theta=270-ang1
            }
            else
            {
                theta=360-ang1

            }
//            if theta! < 180 && bvalue{
//
//                if theta! > 170{
//                    bvalue=false
//
//                }
//
//
//
//                                }
//            if !bvalue{
//                                    theta = 360 - theta!
//
//                }
//                showAngle.layer.cornerCurve
            
           // showAngle.text=String(theta!)
                
            print("Angle Printed  =======", ang,"Joints Captured",imagePoints.count)

                                

                                

                                

                                switch theta{

                                

                                case 0..<10:

                                    if angArray[0]==true

                                    {

                                        angArray[0]=false

                                        return textToSpeech(Number: 0)

                                    }

                                    

                                case 28..<35:

                                    

                                    if angArray[30]==true

                                    {

                                        angArray[30]=false

                                        return textToSpeech(Number: 30)

                                    }

                                case 55..<63:

                                    

                                    if angArray[60]==true

                                    {

                                        angArray[60]=false

                                        return textToSpeech(Number: 60)

                                    }

                                case 85..<92:

                                    if angArray[90]==true

                                    {

                                        angArray[90]=false

                                        return textToSpeech(Number: 90)

                                    }

                                case 115..<123:


                                    if angArray[120]==true

                                    {

                                        angArray[120]=false

                                        return textToSpeech(Number: 120)

                                    }

                                case 145..<153:


                                    if angArray[150]==true

                                    {

                                        angArray[150]=false

                                        return textToSpeech(Number: 150)

                                    }

                                case 170..<185:

                                    if angArray[180]==true

                                    {

                                        angArray[180]=false

                                        return textToSpeech(Number: 180)

                                    }

                                case 205..<213:


                                    if angArray[210]==true

                                    {

                                        angArray[210]=false

                                        return textToSpeech(Number: 210)

                                    }

                                case 235..<243:


                                    if angArray[240]==true

                                    {

                                        angArray[240]=false

                                        return textToSpeech(Number: 240)

                                    }

                                case 265..<273:


                                    if angArray[270]==true

                                    {

                                        angArray[270]=false

                                        return textToSpeech(Number: 270)

                                    }

                                case 295..<303:


                                    if angArray[300]==true

                                    {

                                        angArray[300]=false

                                        return textToSpeech(Number: 300)

                                    }

                                case 325..<333:

                                    if angArray[330]==true

                                    {

                                        angArray[330]=false

                                        return textToSpeech(Number: 330)

                                    }

                                case 340..<360:


                                    if angArray[360]==true

                                    {

                                        angArray[360]=false

                                        return textToSpeech(Number: 360)

                                    }

                                default:

                                    return

                                }
            //}
            }

            // Draw the points onscreen.

           // draw(points: imagePoints)

          //  print("imagepoint",imagePoints)

        }
    func textToSpeech(Number: Int){

            let utterance = AVSpeechUtterance(string: "\(Number) Degrees")



            // Configure the utterance.

            utterance.rate = 0.57

            utterance.pitchMultiplier = 0.8

            utterance.postUtteranceDelay = 0.2

            utterance.volume = 0.8



            // Retrieve the British English voice.

    //        let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-GB_compact")



            // Assign the voice to the utterance.

            utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-GB_compact")

            

            let synthesizer = AVSpeechSynthesizer()

            synthesizer.speak(utterance)

        }
    func texttospeech(Number: String){

            let utterance = AVSpeechUtterance(string: Number)



            // Configure the utterance.

            utterance.rate = 0.57

            utterance.pitchMultiplier = 0.8

            utterance.postUtteranceDelay = 0.2

            utterance.volume = 0.8



            // Retrieve the British English voice.

    //        let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-GB_compact")



            // Assign the voice to the utterance.

            utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-GB_compact")

            

            let synthesizer = AVSpeechSynthesizer()

            synthesizer.speak(utterance)

        }
    func distance3D(vector1: simd_float3, vector2: simd_float3) -> Float
        {
            let x: Float = (vector1.x - vector2.x) * (vector1.x - vector2.x)
            let y: Float = (vector1.y - vector2.y) * (vector1.y - vector2.y)
            let z: Float = (vector1.z - vector2.z) * (vector1.z - vector2.z)

            let temp = x + y + z
            return Float(sqrtf(Float(temp)))
        }
    func keepRadius(){
        let r = Double(self.distance3D(vector1: leftshld1, vector2: rightshld1))/2
    }
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .notAvailable:
      self.trackingStatus = "Tracking:  Not available!"
    case .normal:
      self.trackingStatus = ""
    case .limited(let reason):
      switch reason {
      case .excessiveMotion:
        self.trackingStatus = "Tracking: Limited due to excessive motion!"
      case .insufficientFeatures:
        self.trackingStatus = "Tracking: Limited due to insufficient features!"
      case .relocalizing:
        self.trackingStatus = "Tracking: Relocalizing..."
      case .initializing:
        self.trackingStatus = "Tracking: Initializing..."
      @unknown default:
        self.trackingStatus = "Tracking: Unknown..."
      }
    }
  }
  

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        self.trackingStatus = "AR Session Failure: \(error)"
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                if let configuration = self.session.configuration {
                    self.session.run(configuration, options: .resetSceneReconstruction)
                }
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

  func sessionWasInterrupted(_ session: ARSession) {
    self.trackingStatus = "AR Session Was Interrupted!"
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    self.trackingStatus = "AR Session Interruption Ended"
  }
}
// MARK: - Scene Management
extension ViewController: PoseNetDelegate {
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        defer {
            // Release `currentFrame` when exiting this method.
            self.currentFrame = nil
        }
print("hii")
        guard let currentFrame = currentFrame else {
            return
        }

        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: currentFrame)

        let poses = [poseBuilder.pose]
        
            

    }
}
extension ViewController {
  /**
  func initScene() {
    let scene = SCNScene()
    sceneView.scene = scene
    sceneView.delegate = self
  }
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.updateStatus()
    }
  }
  
  func updateStatus() {
    switch appState {
    case .DetectSurface:
      statusMessage = "Scan available flat surfaces..."
    case .PointAtSurface:
      statusMessage = "Point at designated surface first!"
    case .TapToStart:
      statusMessage = "Tap to start."
    case .Started:
      statusMessage = "Tap objects for more info."
    }
    
    self.statusLabel.text = trackingStatus != "" ?
      "\(trackingStatus)" : "\(statusMessage)"
  } **/
}

// MARK: - Focus Node Management

