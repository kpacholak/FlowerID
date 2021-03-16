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
    
    private let imagePicker = UIImagePickerController()
    private let flowerManager = FlowerManager()
    private var flowerName = ""
    private var flowerDescription = ""
    private var flowerURL = ""
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isHidden = true
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        flowerManager.delegate = self
        imagePicker.delegate = self
    }
    
    
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        let items = ["https://en.wikipedia.org/wiki/\(flowerName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) ?? "rose")"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    
    // func picking image from the camera
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            // to use image with detect() function we need to convert it to CIImage
            guard let convertedCiImage = CIImage(image: userPickedImage) else { fatalError("Unable to convert to CIImage") }
      
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
            self.flowerDescription = "🌸 Wikipedia essence:\n\n" + extract
            self.flowerURL = imageSrcURL
            self.shareButton.isHidden = false
            self.spinner.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            
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

// MARK: - TableView data source delegate methods

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! TableViewCell
        
        cell.cellLabel.text = flowerDescription
        cell.flowerImage.sd_setImage(with: URL(string: flowerURL))
        
        return cell
    }
}

// MARK: - Bar Button isHidden extension

public extension UIBarButtonItem {
    
    var isHidden: Bool {
        get {
            return tintColor == UIColor.clear
        }
        set(hide) {
            if hide {
                isEnabled = false
                tintColor = UIColor.clear
            } else {
                isEnabled = true
                tintColor = nil
                // This sets the tinColor back to the default. If you have a custom color, use that instead
            }
        }
    }
}
