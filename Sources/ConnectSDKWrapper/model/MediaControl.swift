//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 29/04/2024.
//

import Foundation

/**
 An enumeration representing media control capabilities.
 */
public enum MediaControl: String {
    case any = "MediaControl.Any"
    
    case play = "MediaControl.Play"
    case pause = "MediaControl.Pause"
    case stop = "MediaControl.Stop"
    case duration = "MediaControl.Duration"
    case rewind = "MediaControl.Rewind"
    case fastForward = "MediaControl.FastForward"
    case seek = "MediaControl.Seek"
    case playState = "MediaControl.PlayState"
    case playStateSubscribe = "MediaControl.PlayState.Subscribe"
    case position = "MediaControl.Position"
    case metadata = "MediaControl.MetaData"
    case metadataSubscribe = "MediaControl.MetaData.Subscribe"
}
