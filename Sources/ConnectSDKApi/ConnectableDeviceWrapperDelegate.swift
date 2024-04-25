//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//

import Foundation
import ConnectSDK

public protocol ConnectableDeviceWrapperDelegate {
    func device(didConnected device: DeviceWrapper)
    func device(didDisconnected device: DeviceWrapper, withError error: Error)
}
