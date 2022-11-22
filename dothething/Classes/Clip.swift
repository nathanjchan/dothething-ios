//
//  Clip.swift
//  dothething
//
//  Created by Nathan Chan on 11/21/22.
//

import SwiftUI

struct ClipMetadata: Codable, Hashable {
    let code: String
    let id: String
    let timeOfCreation: String
    let thumbnailBase64: String
}

struct Clip: Hashable {
    let thumbnail: UIImage
    let isHighlighted: Bool
    let metadata: ClipMetadata
    let showCode: Bool
    let nextClipId: String?
    
    init(thumbnail: UIImage, isHighlighted: Bool, metadata: ClipMetadata, showCode: Bool, nextClipId: String?) {
        self.thumbnail = thumbnail
        self.isHighlighted = isHighlighted
        self.metadata = metadata
        self.showCode = showCode
        self.nextClipId = nextClipId
    }
}
