//
//  DeviceServiceWrapper.swift
//  
//
//  Created by Stephane SIMO MBA on 29/04/2024.
//

import Foundation
import ConnectSDK
import SmartView

/**
 A wrapper for a ConnectSDK DeviceService.
 */
public struct DeviceServiceWrapper {
    /// The underlying ConnectSDK DeviceService.
    private var deviceService: DeviceService? = nil
    
    /// The underlying SmartView Service.
    private var smartViewService: Service? = nil
    
    /**
     Initializes a new DeviceServiceWrapper with the specified DeviceService.
     
     - Parameter deviceService: The DeviceService to wrap.
     */
    init(_ service: Service) {
        self.smartViewService = service
    }
    
    /**
     Initializes a new DeviceServiceWrapper with the specified DeviceService.
     
     - Parameter deviceService: The DeviceService to wrap.
     */
    init(_ deviceService: DeviceService) {
        self.deviceService = deviceService
    }
    
    /// Indicates whether the service is connectable.
    public var isConnectable: Bool {
        return deviceService?.isConnectable ?? true
    }
    
    /// The name of the service.
    public var name: String? {
        return deviceService?.serviceName ?? smartViewService?.name
    }
    
    /// Indicates whether the service requires pairing.
    public var requiresPairing: Bool {
        return deviceService?.requiresPairing ?? true
    }
    
    /// The capabilities of the service.
    public var capabilities: [MediaControl] {
        return deviceService?.capabilities
            .compactMap { $0 as? String }
            .compactMap { MediaControl(rawValue: $0) } ?? []
    }
    
    /**
     Checks if the service has the specified capability.
     
     - Parameter capability: The capability to check.
     - Returns: `true` if the service has the capability, otherwise `false`.
     */
    public func hasCapability(_ capability: MediaControl) -> Bool {
        return deviceService?.hasCapability(capability.rawValue) ?? true
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

