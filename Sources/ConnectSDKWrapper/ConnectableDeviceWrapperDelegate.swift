//
//  ConnectableDeviceWrapperDelegate.swift
//  
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//

import Foundation
import ConnectSDK

/**
 A protocol for delegates handling events related to ConnectableDeviceWrapper.
 */
public protocol ConnectableDeviceWrapperDelegate: AnyObject {
    /**
     Called when a device is connected.
     
     - Parameter device: The connected device.
     */
    func device(didConnected device: DeviceWrapper)
    
    /**
     Called when a device is disconnected.
     
     - Parameters:
       - device: The disconnected device.
       - error: An optional Error indicating the reason for disconnection.
     */
    func device(didDisconnected device: DeviceWrapper, withError error: Error)
    
    /**
     Called when pairing is required with a service of a device.
     
     - Parameters:
       - device: The device requiring pairing.
       - service: The service requiring pairing.
       - pairingType: The type of pairing required.
     */
    func device(_ device: DeviceWrapper, service: DeviceServiceWrapper, pairingRequiredOfType pairingType: Int32)
    
    /**
     Called when pairing with a service of a device has failed.
     
     - Parameters:
       - device: The device that failed pairing.
       - service: The service that failed pairing.
       - error: An optional Error indicating the reason for failure.
     */
    func device(_ device: DeviceWrapper, service: DeviceServiceWrapper, pairingFailedWithError error: Error)
    
    /**
     Called when pairing with a service of a device has succeeded.
     
     - Parameters:
       - device: The device that succeeded pairing.
       - service: The service that succeeded pairing.
     */
    func deviceParingSucced(_device: DeviceWrapper, service: DeviceServiceWrapper)
}
