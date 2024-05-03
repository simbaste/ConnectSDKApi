//
//  DiscoveryManagerWrapperDelegate.swift
//  
//
//  Created by Stephane SIMO MBA on 24/04/2024.
//

import Foundation
import ConnectSDK

/**
 A protocol for delegates handling events related to DiscoveryManagerWrapper.
 */
public protocol DiscoveryManagerWrapperDelegate: AnyObject {
    /**
     Called when devices are found during discovery.
     
     - Parameter devices: The discovered devices.
     */
    func didFind(_ devices: [DeviceWrapper])
    
    /**
     Called when an error occurs during discovery.
     
     - Parameter error: The error that occurred.
     */
    func didFail(with error: Error)
}

