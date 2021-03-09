//
//  ViewController.swift
//  FlowerID
//
//  Created by Krzysztof Pacholak on 04/03/2021.
//

import UIKit
import CoreML
import Vision
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    let flowerManager = FlowerManager()
    var flowerName = "Rose"
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flowerManager.delegate = self
        imagePicker.delegate = self
    }
    
    // func picking image from the camera
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            // to use image with detect() function we need to convert it to CIImage
            guard let convertedCiImage = CIImage(image: userPickedImage) else { fatalError("Unable to convert to CIImage") }
      
            imageView.image = userPickedImage
            spinner.startAnimating()
            detect(image: convertedCiImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    private func detect(image: CIImage) {
        
        // VNCoreModel comes from Vision library. Loading model
        let config = MLModelConfiguration()
        guard let coreMLModel = try? FlowerClassifier(configuration: config),
              let model = try? VNCoreMLModel(for: coreMLModel.model) else { fatalError("Loading CoreML Model Failed") }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else { fatalError("Unable to classify image") }

            // Result from classifictaion goes to navigation title (capitalized)
            self.navigationItem.title = classification.identifier.capitalized
            let flowerStringName = self.navigationItem.title?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
            self.flowerManager.fetchData(flowerName: flowerStringName ?? "rose")
            
            if let flowerSafeName = self.navigationItem.title {
                self.flowerName = flowerSafeName
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    
    // MARK: - CameraButtonPressed with alerts
    
    @IBAction private func cameraButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(
            title: "Choose image to identify",
            message: nil,
            preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(
            title: "Camera",
            style: .default,
            handler: { _ in
                self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(
            title: "Photo library",
            style: .default,
            handler: { _ in
                self.openLibrary()
        }))
        
        alert.addAction(UIAlertAction.init(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Choose camera or library
    
    private func openCamera() {
        
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
            
        } else {
            
            let alert  = UIAlertController(
                title: "Warning",
                message: "Camera not found",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            ))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func openLibrary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - FlowerManager Delegate Methods

extension ViewController: FlowerManagerDelegate {
    
    func didUpdateFlower(extract: String, imageSrcURL: String) {
        DispatchQueue.main.async {
            self.textView.text = extract
            self.imageView.sd_setImage(with: URL(string: imageSrcURL))
            self.spinner.stopAnimating()
        }
    }
    
    func didFailWithError() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.textView.text = ""
            
            let alert = UIAlertController(
                title: "Warning",
                message: "Unfortunately, there is no information about \(self.flowerName) in Wikipedia",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            ))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
