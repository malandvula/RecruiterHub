//
//  ChatModels.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/8/21.
//

import Foundation
import CoreLocation
import MessageKit

public struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    var photURL: String
    var senderId: String
    var displayName: String
    
}

public struct Media: MediaItem {
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize
}

struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
}

