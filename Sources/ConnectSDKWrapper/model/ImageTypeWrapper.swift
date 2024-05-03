//
//  ImageTypeWrapper.swift
//  
//
//  Created by Stephane SIMO MBA on 02/05/2024.
//

import Foundation

enum ImageTypeWrapper: UInt {
    /*! Unknown to the SDK, may not be used unless you extend Connect SDK to add additional functionality */
    case unknown = 0

    /*! Icon or thumbnail image; mostly used by the MediaPlayer capability to provide an icon for media playback. */
    case thumb = 1

    /*! Large-sized poster image for use by MediaPlayer capability when displaying video. It is recommended that your poster image is the same size as the target video player (full HD, in most cases). */
    case videoPoster = 2

    /*! Album art image for use when playing audio through the MediaPlayer capability. */
    case albumArt = 3
}
