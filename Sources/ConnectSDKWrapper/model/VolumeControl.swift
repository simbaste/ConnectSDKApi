//
//  VolumeControl.swift
//  
//
//  Created by Stephane SIMO MBA on 29/04/2024.
//

import Foundation

/**
 An enumeration representing volume control capabilities.
 */
public enum VolumeControl: String {
    case any = "VolumeControl.Any"
    
    case volumeGet = "VolumeControl.Get"
    case volumeSet = "VolumeControl.Set"
    case volumeUpDown = "VolumeControl.UpDown"
    case volumeSubscribe = "VolumeControl.Subscribe"
    case muteGet = "VolumeControl.Mute.Get"
    case muteSet = "VolumeControl.Mute.Set"
    case muteSubscribe = "VolumeControl.Mute.Subscribe"
}
