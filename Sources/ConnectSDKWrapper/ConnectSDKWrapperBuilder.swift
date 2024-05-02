//
//  File.swift
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
    private var discoveryManager: DiscoveryManager = DiscoveryManager.shared()
    
    /**
     Sets the platforms for the ConnectSDKWrapper.
     
     - Parameters:
       - platforms: A dictionary containing the platform names and their associated discovery provider names.
     */
    public func setConnectSDKPlatforms(platforms: [String: String]) {
        ConnectSDKWrapper.defaultPlatforms = platforms
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
     Sets the DiscoveryManager for the ConnectSDKWrapper.
     
     - Parameters:
       - discoveryManager: The DiscoveryManager instance.
     
     - Returns: The builder instance.
     */
    public func setDiscoveryManager(_ discoveryManager: DiscoveryManager) -> Self {
        self.discoveryManager = discoveryManager
        return self
    }
    
    /**
     Builds and returns an instance of ConnectSDKWrapper with the specified configurations.
     
     - Returns: An instance of ConnectSDKWrapper.
     */
    public func build() -> ConnectSDKWrapper {
        let connectSDKWrapper = ConnectSDKWrapper()
        connectSDKWrapper.delegate = delegate
        discoveryManager.pairingLevel = DeviceServicePairingLevelOn
        connectSDKWrapper.discoveryManager = discoveryManager
        connectSDKWrapper.registerServices()
        return connectSDKWrapper
    }
}


