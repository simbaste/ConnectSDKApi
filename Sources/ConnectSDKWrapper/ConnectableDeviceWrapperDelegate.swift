//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//

import Foundation
import ConnectSDK

public protocol ConnectableDeviceWrapperDelegate: AnyObject {
    func device(didConnected device: DeviceWrapper)
    func device(didDisconnected device: DeviceWrapper, withError error: Error)
    func device(_ device: DeviceWrapper, service: DeviceServiceWrapper, pairingRequiredOfType pairingType: Int32)
    func device(_ device: DeviceWrapper, service: DeviceServiceWrapper, pairingFailedWithError error: (any Error)!)
    func deviceParingSucced(_device: DeviceWrapper, service: DeviceServiceWrapper)
}
