//
//  CameraViewController.swift
//  legoify
//
//  Created by Max Lopez on 4/20/25.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var capturedImage: UIImage?
    var usingFrontCamera = false
    var photoOutput = AVCapturePhotoOutput()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var videoInput: AVCaptureDeviceInput!

        
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var selectFromGalleryButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    
    @IBAction func selectFromGallery(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    @IBAction func switchCameraTapped(_ sender: UIButton) {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        
        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        
        usingFrontCamera.toggle()
        let newPosition: AVCaptureDevice.Position = usingFrontCamera ? .front : .back
        if let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition), let newInput = try? AVCaptureDeviceInput(device: newDevice) {
            captureSession.addInput(newInput)
            videoInput = newInput
        } else {
            captureSession.addInput(currentInput)
        }
        captureSession.commitConfiguration()
    }
    @IBAction func capturePhoto(_ sender: UIButton) {
        sender.isEnabled = false // Prevent spamming
        let activity = UIActivityIndicatorView(style: .medium)
            activity.center = sender.center
            sender.superview?.addSubview(activity)
            activity.startAnimating()
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureButton.setImage(UIImage(named: "cameraButton"), for: .normal)
        captureButton.setImage(UIImage(named: "cameraButtonPressed"), for: .highlighted)
        setupCamera()
    }
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Your device has no camera")
            return
        }
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("Could not add video input")
                return
            }
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            } else {
                print("Could not add photo output")
                return
            }
        } catch {
            print("Error creating video input: \(error)")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Could not get image from photo data")
            return
        }
        
        capturedImage = image
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        performSegue(withIdentifier: "toLoading", sender: self)
        CATransaction.commit()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            capturedImage = image
            performSegue(withIdentifier: "toLoading", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLoading",
           let loadingVC = segue.destination as? LoadingViewController {
            loadingVC.capturedImage = self.capturedImage
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraView.bounds
    }
}
