//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 29/04/2024.
//

import Foundation
import ConnectSDK

public struct DeviceServiceWrapper {
    private let deviceService: DeviceService
    
    init(_ deviceService: DeviceService) {
        self.deviceService = deviceService
    }
    
    public var isConnectable: Bool {
        return deviceService.isConnectable
    }
    
    public var name: String {
        return deviceService.serviceName
    }
    
    public var requiresPairing: Bool {
        return deviceService.requiresPairing
    }
    
    public var capabilities: [MediaControl] {
        return deviceService.capabilities
            .compactMap { $0 as? String }
            .compactMap { MediaControl(rawValue: $0) }
    }
                                       
    public func hasCapability(_ capability: MediaControl) -> Bool {
        return deviceService.hasCapability(capability.rawValue)
    }
    
    public func hasCapabilities(_ capabilities: [MediaControl]) -> Bool {
        return capabilities.allSatisfy { hasCapability($0) }
    }
    
    public func hasCapability(_ capability: VolumeControl) -> Bool {
        return deviceService.hasCapability(capability.rawValue)
    }
    
    public func hasCapabilities(_ capabilities: [VolumeControl]) -> Bool {
        return capabilities.allSatisfy { hasCapability($0) }
    }
    
}
