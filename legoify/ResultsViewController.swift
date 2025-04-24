//
//  ResultsViewController.swift
//  legoify
//
//  Created by Max Lopez on 4/20/25.
//

import UIKit
import Photos

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    var legoifiedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = legoifiedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            // Find the camera view controller in the navigation stack
            if let cameraVC = navigationController?.viewControllers.first(where: { $0 is CameraViewController }) {
                navigationController?.popToViewController(cameraVC, animated: true)
            }
        }
    }
    @IBAction func downloadImageTapped(_ sender: UIButton) {
        guard let image = legoifiedImage else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Permission Denied", message: "You must allow this app to access your Photos library to download your image.")
                }
            }
        }
        
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            if let error = error {
                self.showAlert(title: "Save Failed", message: error.localizedDescription)

            } else {
                self.showAlert(title: "Saved!", message: "Image saved to your Photos.")

            }
        }
    }
    func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
}
