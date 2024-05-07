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
    func didConnect(device: DeviceWrapper)
    
    /**
     Called when a device is disconnected.
     
     - Parameters:
       - device: The disconnected device.
       - error: An optional Error indicating the reason for disconnection.
     */
    func didDisconnect(device: DeviceWrapper, withError error: Error?)
    
    /**
     Called when pairing is required with a service of a device.
     
     - Parameters:
       - pairingType: The type of pairing required.
       - device: The device requiring pairing.
       - service: The service requiring pairing.
     */
    func didRequirePairing(ofType pairingType: Int32, with device: DeviceWrapper, service: DeviceServiceWrapper)
    
    /**
     Called when pairing with a service of a device has failed.
     
     - Parameters:
       - device: The device that failed pairing.
       - service: The service that failed pairing.
       - error: An optional Error indicating the reason for failure.
     */
    func didFailToPair(device: DeviceWrapper, service: DeviceServiceWrapper, withError error: Error)

    /**
     Called when pairing with a service of a device has succeeded.
     
     - Parameters:
       - device: The device that succeeded pairing.
       - service: The service that succeeded pairing.
     */
    func didPair(device: DeviceWrapper, service: DeviceServiceWrapper)
}
