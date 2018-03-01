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
import SwiftOCR

struct Bookmark {
    //Variables set to default
    var pageNumber: String! = "No page num found"
    var chapterNumber: String! = "No chapter num found"
    var newBookPageImage: UIImage! = UIImage(named: "no_image")
}


class ViewController: UIViewController, ARSCNViewDelegate, UINavigationControllerDelegate {
    
    //MARK: SETUP VARIABLES
    @IBOutlet weak var symbolTextField: UITextField!
    @IBOutlet weak var rearCameraView: ARSCNView!
    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var visionRequests = [VNRequest]()
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml")
    override var prefersStatusBarHidden: Bool {return true}
    var cameraOn: Bool = false
    var originalImage: UIImage!
    let swiftOCRInstance = SwiftOCR()
    var bookmark: Bookmark?
    
    @IBAction func bookSegue(_ sender: Any) {
        performSegue(withIdentifier: "goToBooks", sender: nil)
    }
    
    //MARK: SETUP SCENE AND ML MODEL
    override func viewDidLoad() {
        super.viewDidLoad()
        rearCameraView.delegate = self
        let scene = SCNScene()
        rearCameraView.scene = scene
        activityIndicator.isHidden = true
        
        //Setup ML Model
        guard let model = try? VNCoreMLModel(for: test_model_3().model)
            else {
                fatalError("Ensure the model is imported correctly. Also make sure model works before adding to project")
        }
        //Setup ML Request
        let classificationRequest = VNCoreMLRequest(model: model, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequests = [classificationRequest]
        
        //Update ML Request
        updateRequest()
        
        //Ensure ARKit is using autofocused - https://stackoverflow.com/questions/46145637/adjust-camera-focus-in-arkit
        let config = ARWorldTrackingConfiguration()
        config.isAutoFocusEnabled = true
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
    
    //MARK: IMAGE RECOG CLASSIFICATION
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
            .compactMap({ $0 as? VNClassificationObservation }) //Changed from flatMap -> compactMap. Test to ensure working
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
                if (topPredictionName == "book" && topPredictionScore! > 0.60) {
                    symbol = "BOOK";
                    self.cameraOn = true;
                    //Takes automatic picture of book page
                    self.takePicture()
                }
                if (topPredictionName == "no-book") {
                    symbol = "NO BOOK";
                    self.cameraOn = false
                }
            }
            
            self.symbolTextField.text = symbol
        }
    }
    
    //MARK: MIGHT GO IN PAGEREVIEWCONTROLLER CLASS
    private func ocrRecgonize(){
        if let pic = self.originalImage {
            swiftOCRInstance.recognize(pic) { recognizedString in
                DispatchQueue.main.async(execute: {
                    print("Recognizing bookpage...")
                    print(recognizedString)
                })
            }
        }
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
        performSegue(withIdentifier: "bookmarking", sender: nil)
    }
    
    //MARK: DEPRECATED
    func cameraHidden() {
        if(self.cameraOn) {}
    }
    
    //MARK: SESSION ERROR HANDLING
    func session(_ session: ARSession, didFailWithError error: Error) {
        fatalError("Session failed with error: \(error)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        fatalError("Session has been interrupted!")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
}

//MARK: THIS SCALES ALL IMAGES TO BEST FORMAT FOR OCR IMAGE RECOG
extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if scaledSize.width > scaledSize.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        }else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let rescaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rescaledImage
    }
}

//MARK: SETUPS CAMERA AND AUTO TAKES PICTURE
extension ViewController : UIImagePickerControllerDelegate {
    func takePicture(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.showsCameraControls = false
        imagePicker.isNavigationBarHidden = true
        
        //Takes picture automatically
        present(imagePicker, animated: true, completion: {
            imagePicker.takePicture()
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage {
            var scaledImage = selectedPhoto.scaleImage(640) //This should be the new bookPage image
            
            /*Testing*/
            bookmark?.newBookPageImage = scaledImage
            /*//Testing*/
            
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            dismiss(animated: true, completion: {
                self.ocrRecgonize()
            })
        }
    }
}




