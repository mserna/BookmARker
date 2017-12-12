//
//  ViewController.swift
//  Use only for testing new features
//  BookmARker
//
//  Created by Matthew Serna on 10/2/17.
//  Copyright © 2017 Matthew Serna. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var symbolTextField: UITextField!
    @IBOutlet weak var rearCameraView: ARSCNView!
    @IBOutlet weak var debugTextView: UITextView!
    var visionRequests = [VNRequest]()
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml")
    override var prefersStatusBarHidden: Bool {return true}
    var cameraOn: Bool = false
    @IBOutlet weak var cameraImage: UIImageView!
    var originalImage: UIImage!
    var editedImage: UIImage!
    
    //MARK: SETUP SCENE AND ML MODEL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rearCameraView.delegate = self
        let scene = SCNScene()
        rearCameraView.scene = scene
        
        //Camera functionality
        self.cameraHidden()
        
        //--Machine Learning and Deep learning--//
        
        //Setup ML Model
        guard let model = try? VNCoreMLModel(for: test2().model)
            else {
                fatalError("Ensure the model is imported correctly. Also make sure model works before adding to project")
            }
        //Setup ML Request
        let classificationRequest = VNCoreMLRequest(model: model, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequests = [classificationRequest]
        
        //Update ML Request
        updateRequest()
    }
    
    //MARK: AR TRACKING CONFIG
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration() // Create a session configuration
        rearCameraView.session.run(configuration) // Run the view's session
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rearCameraView.session.pause() // Pause the view's session
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            // Do any desired updates to SceneKit here.
        }
    }
    
    //MARK: UPDATES
    
    func updateRequest() {
        dispatchQueueML.async {
            self.updateCoreML() //Run updates
            self.updateRequest() //Loop this async task
        }
    }
    
    func updateCoreML() {
        let pixelBuffer: CVPixelBuffer? = (rearCameraView.session.currentFrame?.capturedImage)
        if pixelBuffer == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do{
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
    
    func classificationCompleteHandler(request: VNRequest, error: Error?){
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        //Grabbed from MIT Open Source License repo and edited for my model
        let classifications = observations[0...1] // Either book or no book
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.debugTextView.text = " \n\n Result percentages: \n" + classifications
            
            // Display Top Symbol
            var symbol = "NO BOOK"
            let topPrediction = classifications.components(separatedBy: "\n")[0]
            let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            // Only display a prediction if confidence is above 1%
            let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
            if (topPredictionScore != nil && topPredictionScore! > 0.01) {
                if (topPredictionName == "book") { symbol = "BOOK"; self.cameraOn = true }
                if (topPredictionName == "no-book") { symbol = "NO BOOK"; self.cameraOn = false}
            }
            
            self.symbolTextField.text = symbol
        }
    }
    
    //MARK: CAMERA BUTTON FUNCTIONALITY
    @IBAction func enableCamera(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        dismiss(animated: true, completion: nil)
    }
    
    func cameraHidden() {
        if(self.cameraOn) {
            //TODO: ENABLE CAMERA BUTTON
            self.cameraImage.isHidden = false
        }
    }
    
    //MARK: SESSION ERROR HANDLING
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        fatalError("Session failed with error: \(error)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        fatalError("Session has been interrupted!")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        //TODO
    }
}
