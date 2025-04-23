//
//  LoadingViewController.swift
//  legoify
//
//  Created by Max Lopez on 4/20/25.
//

import UIKit

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

class LoadingViewController: UIViewController {
    var capturedImage: UIImage?
    var apiKey = "API KEY"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLegoifyProcess()
    }
    func startLegoifyProcess() {
        guard let image = capturedImage,
              let imageData = image.jpegData(compressionQuality: 0.9) else {
            print("failed to convert image")
            return
        }
        sendImageToStableImageUltra(imageData: imageData)
    }
    func sendImageToStableImageUltra(imageData: Data) {
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "https://api.stability.ai/v2beta/stable-image/generate/ultra")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        var body = Data()
        let prompt = "a photo of a LEGO version of this image, vibrant colors, toy style, plastic texture"
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n")
        body.append("\(prompt)\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"strength\"\r\n\r\n")
        body.append("0.6\r\n") // controls how "legoified" the result is

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"input.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("API error: \(error?.localizedDescription ?? "Unkown error")")
                return
            }
            
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toResults", sender: image)
                }
            } else {
                print("Failed to parse returned image")
            }
        }.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResults",
           let resultVC = segue.destination as? ResultsViewController,
           let image = sender as? UIImage {
            resultVC.legoifiedImage = image
        }
    }
}
