//
//  ImagePicker.swift
//  intercut
//
//  Created by Nathan Chan on 9/21/22.
//

import Foundation
import AVKit
import SwiftUI

protocol ImagePickerMessenger {
    func upload(videoUrl: URL)
    func cancel()
}

class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let imagePicker = UIImagePickerController()
    
    // initialize with view model
    var messenger: ImagePickerMessenger
    init(messenger: ImagePickerMessenger) {
        self.messenger = messenger
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.allowsEditing = true
        imagePicker.videoQuality = .typeHigh
        imagePicker.videoExportPreset = AVAssetExportPresetHighestQuality
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Entered imagePickerController")
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
        print("Entered imagePickerControllerDidCancel")
        messenger.cancel()
        picker.dismiss(animated: true, completion: nil)
    }

    func open() {
        print("Entered ImagePicker.open")
        imagePicker.delegate = self

        // verify the device is capable of selecting a video
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("This device is not capable of selecting a video")
            return
        }
        print("This device is capable of selecting a video")

        // present the image picker
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
    }
}
