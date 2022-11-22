//
//  Thinger.swift
//  dothething
//
//  Created by Nathan Chan on 10/21/22.
//

import Foundation
import AVKit

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

class Thinger {
    static func showAlert(title: String, message: String, button: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: button, style: .default, handler: nil))
            
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }

    static func getThumbnail(url: URL, degreesToRotate: Int) -> UIImage {
        print("Entered getThumbnail")
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            
            // rotate image by videoDegreesToRotate
            let rotatedImage = UIImage(cgImage: thumbnailImage).rotate(radians: Float((Float(degreesToRotate + 180) * .pi / 180)))
            return rotatedImage ?? UIImage(cgImage: thumbnailImage)
        } catch let error {
            print("Error creating thumbnail: \(error)")
        }

        return UIImage()
    }

    static func playVideo(videoUrl: URL) {
        DispatchQueue.main.async {
            print("Playing video")
            let player = AVPlayer(url: videoUrl)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            // play audio even if phone muted
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print(error)
            }
            
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            window?.rootViewController?.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    static func showSharePopup(text: String) {
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            
            activityViewController.popoverPresentationController?.sourceView = window?.rootViewController?.view
            window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }

    static func clipsMetadataArrayToClipsArray(cmdArray: [ClipMetadata]) -> [Clip] {
        var clips: [Clip] = []
        for (index, cmd) in cmdArray.enumerated() {
            let dataDecoded = Data(base64Encoded: cmd.thumbnailBase64, options: .ignoreUnknownCharacters)
            let decodedimage = UIImage(data: dataDecoded ?? Data())
            if index < cmdArray.count - 1 {
                clips.append(Clip(thumbnail: decodedimage ?? UIImage(), isHighlighted: false, metadata: cmd, showCode: false, nextClipId: cmdArray[index + 1].id))
            } else {
                clips.append(Clip(thumbnail: decodedimage ?? UIImage(), isHighlighted: false, metadata: cmd, showCode: false, nextClipId: nil))
            }
        }
        return clips
    }
}
