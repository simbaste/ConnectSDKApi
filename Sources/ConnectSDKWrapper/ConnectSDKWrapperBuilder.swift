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
    
    private var delegate: DiscoveryManagerWrapperDelegate?
    
    public init() {}
    
    /**
     Sets the platforms for the ConnectSDKWrapper.
     
     - Parameters:
       - platforms: A dictionary containing the platform names and their associated discovery provider names.
     */
    public func setConnectSDKPlatforms(platforms: [String: String]) -> Self {
        ConnectSDKWrapper.defaultPlatforms = platforms
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


