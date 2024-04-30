//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 29/04/2024.
//

import Foundation
import ConnectSDK

/**
 A wrapper for a ConnectSDK DeviceService.
 */
public struct DeviceServiceWrapper {
    /// The underlying ConnectSDK DeviceService.
    private let deviceService: DeviceService
    
    /**
     Initializes a new DeviceServiceWrapper with the specified DeviceService.
     
     - Parameter deviceService: The DeviceService to wrap.
     */
    init(_ deviceService: DeviceService) {
        self.deviceService = deviceService
    }
    
    /// Indicates whether the service is connectable.
    public var isConnectable: Bool {
        return deviceService.isConnectable
    }
    
    /// The name of the service.
    public var name: String {
        return deviceService.serviceName
    }
    
    /// Indicates whether the service requires pairing.
    public var requiresPairing: Bool {
        return deviceService.requiresPairing
    }
    
    /// The capabilities of the service.
    public var capabilities: [MediaControl] {
        return deviceService.capabilities
            .compactMap { $0 as? String }
            .compactMap { MediaControl(rawValue: $0) }
    }
    
    /**
     Checks if the service has the specified capability.
     
     - Parameter capability: The capability to check.
     - Returns: `true` if the service has the capability, otherwise `false`.
     */
    public func hasCapability(_ capability: MediaControl) -> Bool {
        return deviceService.hasCapability(capability.rawValue)
    }
    
    /**
     Checks if the service has all of the specified capabilities.
     
     - Parameter capabilities: The capabilities to check.
     - Returns: `true` if the service has all of the capabilities, otherwise `false`.
     */
    public func hasCapabilities(_ capabilities: [MediaControl]) -> Bool {
        return capabilities.allSatisfy { hasCapability($0) }
    }
}

