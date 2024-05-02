//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 02/05/2024.
//

import Foundation
import ConnectSDK

public class MediaPlayerBuilder {
    
    private var device: DeviceWrapper
    private var mediaURL: URL?
    private var iconURL: URL?
    private var title: String?
    private var description: String?
    private var mimeType: String?
    private var subtitlesURL: URL?
    private var loop: Bool = false
    private var subtitleBuilder: ((SubtitleInfoBuilder) -> Void)?
    
    init(device: DeviceWrapper) {
        self.device = device
    }
    
    // Setters for media properties
    
    public func setMediaURL(_ mediaURL: URL?) -> Self {
        self.mediaURL = mediaURL
        return self
    }
    
    public func setIconURL(_ iconURL: URL?) -> Self {
        self.iconURL = iconURL
        return self
    }
    
    public func setTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }
    
    public func setDescription(_ description: String?) -> Self {
        self.description = description
        return self
    }
    
    public func setMimeType(_ mimeType: String?) -> Self {
        self.mimeType = mimeType
        return self
    }
    
    public func setSubtitlesURL(_ subtitlesURL: URL?) -> Self {
        self.subtitlesURL = subtitlesURL
        return self
    }
    
    public func setLoop(_ loop: Bool) -> Self {
        self.loop = loop
        return self
    }
    
    public func setSubtitleBuilder(_ subtitleBuilder: ((SubtitleInfoBuilder) -> Void)?) -> Self {
        self.subtitleBuilder = subtitleBuilder
        return self
    }
    
    // Build method to initiate media playback
    
    public func build(
        success: @escaping (_ succes: MediaLaunchObject?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        let mediaInfo = MediaInfo(url: mediaURL, mimeType: mimeType)
        mediaInfo?.title = title
        mediaInfo?.description = description
        
        // Add icon URL as image info if available
        
        if let iconURL = iconURL {
            let imageInfo = ImageInfo(url: iconURL, type: ImageType(ImageTypeWrapper.thumb.rawValue))
            mediaInfo?.addImage(imageInfo)
        }
        
        // Add subtitles if supported by the device and provided
        
        if device.hasCapability(kMediaPlayerSubtitleWebVTT),
           let subtitlesURL = subtitlesURL,
           let subtitleBuilder = subtitleBuilder {
            let subtitleInfo = SubtitleInfo(url: subtitlesURL, andBlock: subtitleBuilder)
            mediaInfo?.subtitleInfo = subtitleInfo
        }

        // Initiate media playback
        
        device.playMedia(with: mediaInfo, shouldLoop: loop) { launchObject in
            success(launchObject)
            // save the object reference to control media playback
            // enable your media control UI elements here
        } failure: { error in
            NSLog("play video failure: \(error!.localizedDescription)")
            failure(error)
        }
    }
}
