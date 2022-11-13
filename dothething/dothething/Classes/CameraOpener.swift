//
//  CameraOpener.swift
//  dothething
//
//  Created by Nathan Chan on 11/13/22.
//

import Foundation
import AVKit
import SwiftUI

class CameraOpener: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let camera = UIImagePickerController()
    
    // initialize with view model
    var messenger: ImagePickerMessenger
    init(messenger: ImagePickerMessenger) {
        self.messenger = messenger
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Entered CameraOpener.imagePickerController")
        picker.dismiss(animated: true, completion: nil)
        
        // do something with video
        guard let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
            print("No video URL found")
            return
        }
        print("Video URL: \(url)")
        messenger.upload(videoUrl: url)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Entered CameraOpener.imagePickerControllerDidCancel")
        messenger.cancel()
        picker.dismiss(animated: true, completion: nil)
    }

    func open() {
        print("Entered CameraOpener.open")
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("This device is not capable of opening the camera")
            return
        }
        print("This device is capable of opening the camera")
        camera.sourceType = .camera
        camera.allowsEditing = true
        camera.mediaTypes = ["public.movie"]
        camera.videoQuality = .typeHigh
        camera.videoMaximumDuration = 10
        camera.cameraCaptureMode = .video
        camera.cameraDevice = .rear
        camera.cameraFlashMode = .off
        camera.showsCameraControls = true
        camera.delegate = self
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(camera, animated: true, completion: nil)
    }
}

