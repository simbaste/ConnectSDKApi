//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 24/04/2024.
//

import Foundation
import ConnectSDK

public protocol ConnectSDKDelegate: AnyObject {
    func didFindDevices(_ devices: [ConnectableDevice])
    func didFailWithError(_ error: Error)
    func device(didConnected device: ConnectableDevice)
    func device(didDisconnected device: ConnectableDevice, withError error: Error)
}
