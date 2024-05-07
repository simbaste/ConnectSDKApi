//
//  ConnectSDKWrapper.swift
//
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//
// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//

import Foundation
import ConnectSDK

/**
 A wrapper for the ConnectSDK DiscoveryManager.
 */
public class ConnectSDKWrapper: NSObject, DiscoveryManagerDelegate {
    
    static var platforms = [String:String]()
    
    /// The delegate for handling discovery events.
    public weak var delegate: DiscoveryManagerWrapperDelegate?
    
    /// The underlying ConnectSDK DiscoveryManager.
    var discoveryManager: DiscoveryManager
    
    /// The set of discovered devices.
    private var discoveredDevices: Set<DeviceWrapper> = Set()
    
    /**
     Initializes a new ConnectSDKWrapper.
     */
    override init() {
        discoveryManager = DiscoveryManager.shared()
        super.init()
        discoveryManager.delegate = self
        AirPlayService.setAirPlayServiceMode(AirPlayServiceModeMedia)
        DIALService.registerApp("Levak")
    }
    
    public func destry() {
        self.discoveredDevices.removeAll()
        self.discoveryManager.stopDiscovery()
        unregisterServices()
    }
    
    /**
     Starts searching for devices.
     */
    public func searchForDevices() {
        self.discoveredDevices.removeAll()
        self.discoveryManager.startDiscovery()
    }
    
    /**
     Stops searching for devices.
     */
    public func stopSearchingForDevices() {
        self.discoveryManager.stopDiscovery()
    }
    
    /**
     Called when a device is found during discovery.
     
     - Parameters:
       - manager: The DiscoveryManager.
       - device: The discovered ConnectableDevice.
     */
    public func discoveryManager(_ manager: DiscoveryManager!, didFind device: ConnectableDevice!) {
        discoveredDevices.insert(DeviceWrapper(device))
        delegate?.didFind(Array(discoveredDevices))
    }
    
    func registerServices() {
        ConnectSDKWrapper.platforms.forEach { platformClassName, discoveryProviderClassName in
            if let platformClass = NSClassFromString(platformClassName) as? NSObject.Type,
               let discoveryProviderClass = NSClassFromString(discoveryProviderClassName) as? DiscoveryProvider.Type {
                discoveryManager.registerDeviceService(platformClass, withDiscovery: discoveryProviderClass)
            }
        }
    }
    
    func unregisterServices() {
        ConnectSDKWrapper.platforms.forEach { platformClassName, discoveryProviderClassName in
            if let platformClass = NSClassFromString(platformClassName) as? NSObject.Type,
               let discoveryProviderClass = NSClassFromString(discoveryProviderClassName) as? DiscoveryProvider.Type {
                discoveryManager.unregisterDeviceService(platformClass, withDiscovery: discoveryProviderClass)
            }
        }
    }
    
    /**
     Called when a device is lost during discovery.
     
     - Parameters:
       - manager: The DiscoveryManager.
       - device: The lost ConnectableDevice.
     */
    public func discoveryManager(_ manager: DiscoveryManager!, didLose device: ConnectableDevice!) {
        discoveredDevices.remove(DeviceWrapper(device))
        delegate?.didFind(Array(discoveredDevices))
    }
    
    /**
     Called when a device is updated during discovery.
     
     - Parameters:
       - manager: The DiscoveryManager.
       - device: The updated ConnectableDevice.
     */
    public func discoveryManager(_ manager: DiscoveryManager!, didUpdate device: ConnectableDevice!) {
        discoveredDevices.update(with: DeviceWrapper(device))
        delegate?.didFind(Array(discoveredDevices))
    }
}
