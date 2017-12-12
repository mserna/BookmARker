////
////  ImageRecognitionViewController.swift
////  BookmARker
////
////  Created by Matthew Serna on 11/13/17.
////  Copyright © 2017 Matthew Serna. All rights reserved.
////
//
//import UIKit
//import SceneKit
//import ARKit
//import Vision
//
//class ImgageRecognitionViewController: UIViewController, ARSCNViewDelegate {
//
//
//    @IBOutlet weak var rearCameraView: ARSCNView!
//    @IBOutlet weak var debugTextView: UITextView!
//    @IBOutlet weak var symbolTextField: UITextField!
//    var visionRequests = [VNRequest]()
//    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml")
//    override var prefersStatusBarHidden: Bool {return true}
//
//    //MARK: SETUP SCENE AND ML MODEL
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        rearCameraView.delegate = self
//        let scene = SCNScene()
//        rearCameraView.scene = scene
//
//        //--Machine Learning and Deep learning--//
//
//        //Setup ML Model
//        guard let model = try? VNCoreMLModel(for: book_nobook_model().model)
//            else {
//                fatalError("Ensure the model is imported correctly. Also make sure model works before adding to project")
//        }
//        //Setup ML Request
//        let classificationRequest = VNCoreMLRequest(model: model, completionHandler: classificationCompleteHandler)
//        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
//        visionRequests = [classificationRequest]
//
//        //Update ML Request
//        updateRequest()
//    }
//
//    //MARK: AR TRACKING CONFIG
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let configuration = ARWorldTrackingConfiguration() // Create a session configuration
//        rearCameraView.session.run(configuration) // Run the view's session
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        rearCameraView.session.pause() // Pause the view's session
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//
//    //MARK: UPDATES
//
//    func updateRequest() {
//        dispatchQueueML.async {
//            self.updateCoreML() //Run updates
//            self.updateRequest() //Loop this async task
//        }
//    }
//
//    func updateCoreML() {
//        let pixelBuffer: CVPixelBuffer? = (rearCameraView.session.currentFrame?.capturedImage)
//        if pixelBuffer == nil { return }
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer!)
//
//        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
//
//        do{
//            try imageRequestHandler.perform(self.visionRequests)
//        } catch {
//            print(error)
//        }
//    }
//
//    func classificationCompleteHandler(request: VNRequest, error: Error?) {
//        if error != nil {
//            print("Error: " + (error?.localizedDescription)!)
//            return
//        }
//
//        guard let observations = request.results else {
//            print("No results")
//            return
//        }
//
//        //Grabbed from MIT Open Source License repo
//        let classifications = observations[0...2] // top 3 results
//            .flatMap({ $0 as? VNClassificationObservation })
//            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
//            .joined(separator: "\n")
//
//        DispatchQueue.main.async {
//            self.debugTextView.text = "TOP 3 PROBABILITIES: \n" + classifications
//
//            // Display Top Symbol
//            var symbol = "❎"
//            let topPrediction = classifications.components(separatedBy: "\n")[0]
//            let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
//            if (topPredictionName == "book") { symbol = "BOOK" }
//            if (topPredictionName == "no-book") { symbol = "NO BOOK" }
//            self.symbolTextField.text = symbol
//        }
//    }
//
//    //MARK: SESSION ERROR HANDLING
//
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        fatalError("Session failed with error: \(error)")
//    }
//
//    func sessionWasInterrupted(_ session: ARSession) {
//        fatalError("Session has been interrupted!")
//    }
//
//    func sessionInterruptionEnded(_ session: ARSession) {
//        //TODO
//    }
//}
//
