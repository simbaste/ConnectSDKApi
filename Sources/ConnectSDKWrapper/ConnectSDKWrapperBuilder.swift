//
//  ConnectSDKWrapperBuilder.swift
//  
//
//  Created by Stephane SIMO MBA on 02/05/2024.
//

import Foundation
import ConnectSDK

/**
 A builder class for constructing instances of ConnectSDKWrapper.
 */
public class ConnectSDKWrapperBuilder {
    
    /// The default platforms supported by ConnectSDK
    private let defaultPlatforms: [String: String] = [
        "DIALService": "SSDPDiscoveryProvider",
        "DLNAService": "SSDPDiscoveryProvider",
        "NetcastTVService": "SSDPDiscoveryProvider",
        "RokuService": "SSDPDiscoveryProvider",
        "WebOSTVService": "SSDPDiscoveryProvider",
    ]
    
    private var delegate: DiscoveryManagerWrapperDelegate?
    
    public init() {}
    
    /**
     Sets the platforms for the ConnectSDKWrapper.
     
     - Parameters:
       - platforms: A list containing the platform names. Ex: (DIALService, DLNAService, NetcastTVService, NetcastTVService, RokuService, WebOSTVService, CastService, FireTVService)
     */
    public func setConnectSDKPlatforms(platforms: [Platform]) -> Self {
        if platforms.isEmpty {
            ConnectSDKWrapper.platforms = defaultPlatforms
        } else {
            platforms.forEach { platform in
                if let provider = defaultPlatforms[platform.rawValue] {
                    ConnectSDKWrapper.platforms[platform.rawValue] = provider
                }
            }
        }
        return self
    }
    
    /**
     Sets the delegate for the ConnectSDKWrapper.
     
     - Parameters:
       - delegate: The delegate for handling discovery events.
     
     - Returns: The builder instance.
     */
    public func setDelegate(_ delegate: DiscoveryManagerWrapperDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    
    /**
     Builds and returns an instance of ConnectSDKWrapper with the specified configurations.
     
     - Returns: An instance of ConnectSDKWrapper.
     */
    public func build() -> ConnectSDKWrapper {
        let connectSDKWrapper = ConnectSDKWrapper()
        connectSDKWrapper.delegate = delegate
        connectSDKWrapper.discoveryManager.pairingLevel = DeviceServicePairingLevelOn
        connectSDKWrapper.registerServices()
        return connectSDKWrapper
    }
}


