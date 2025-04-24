//
//  LoadingViewController.swift
//  legoify
//
//  Created by Max Lopez on 4/20/25.
//

import UIKit
import WebKit

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

class LoadingViewController: UIViewController {
    
    var webView: WKWebView!
    var animationTimer: Timer?
    
    var capturedImage: UIImage?
    var apiKey = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WebViewPreloader.shared.getWebView()
        webView.frame = self.view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(webView)

        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        // Reload using original file-based URL works correctly now
        animationTimer = Timer.scheduledTimer(withTimeInterval: 7, repeats: true) { [weak self] _ in
            self?.webView.reload()
        }

        startLegoifyProcess()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the back button
        self.navigationItem.hidesBackButton = true
        
        // Disable the interactive pop gesture (swipe back)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    func startLegoifyProcess() {
        print("starting legoify process")
        guard let image = capturedImage,
              let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("failed to convert image")
            return
        }
        sendImageToOpenAIEdit(imageData: imageData)
    }
    func sendImageToOpenAIEdit(imageData: Data) {
        guard let url = URL(string: "https://api.openai.com/v1/images/edits") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Prompt
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n")
        body.append("Make this image into Lego\r\n")

        // Model
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n")
        body.append("gpt-image-1\r\n")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"size\"\r\n\r\n")
        body.append("1024x1536\r\n")

        // Image
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"input.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")

        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        request.timeoutInterval = 200

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data returned.")
                return
            }

            // Debug output
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response:\n\(jsonString)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]],
                   let base64String = dataArray.first?["b64_json"] as? String,
                   let imageBytes = Data(base64Encoded: base64String),
                   let image = UIImage(data: imageBytes) {
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toResults", sender: image)
                    }
                } else {
                    print("Failed to decode image from JSON.")
                }
            } catch {
                print("JSON decoding error: \(error)")
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
