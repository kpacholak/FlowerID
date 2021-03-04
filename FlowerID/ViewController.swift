//
//  ViewController.swift
//  FlowerID
//
//  Created by Krzysztof Pacholak on 04/03/2021.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    
    }

    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
    }
    
}

