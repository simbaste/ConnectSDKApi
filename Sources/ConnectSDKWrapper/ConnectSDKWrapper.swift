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
import SmartView

/**
 A wrapper for the ConnectSDK DiscoveryManager.
 */
public class ConnectSDKWrapper: NSObject, DiscoveryManagerDelegate, ServiceSearchDelegate {
    
    static var platforms = [String:String]()
    
    /// The delegate for handling discovery events.
    public weak var delegate: DiscoveryManagerWrapperDelegate?
    
    /// The underlying ConnectSDK DiscoveryManager.
    var discoveryManager: DiscoveryManager
    
    /// The set of discovered devices.
    private var discoveredDevices: Set<DeviceWrapper> = Set()
    
    /// SmartView Service Search
    var serviceSearch: ServiceSearch? = nil
    
    /**
     Initializes a new ConnectSDKWrapper.
     */
    override init() {
        discoveryManager = DiscoveryManager()
        super.init()
        discoveryManager.delegate = self
        DIALService.registerApp("Levak")
        
    
    }
    
    public func destry() {
        self.discoveredDevices.removeAll()
        self.discoveryManager.stopDiscovery()
        serviceSearch?.stop() // Stop SmartView service search
        unregisterServices()
    }
    
    /**
     Starts searching for devices.
     */
    public func searchForDevices() {
        self.discoveredDevices.removeAll()
        self.discoveryManager.startDiscovery()
        serviceSearch?.start()
    }
    
    /**
     Stops searching for devices.
     */
    public func stopSearchingForDevices() {
        self.discoveryManager.stopDiscovery()
        serviceSearch?.stop() // Stop SmartView service Search
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
    
    // MARK: - ServiceSearchDelegate
    
    public func onServiceFound(_ service: Service) {
        let deviceWrapper = DeviceWrapper(service: service)
        discoveredDevices.insert(deviceWrapper)
        delegate?.didFind(Array(discoveredDevices))
    }
    
    public func onServiceLost(_ service: Service) {
        if let deviceWrapper = discoveredDevices.first(where: { $0.smartViewService?.id == service.id }) {
            discoveredDevices.remove(deviceWrapper)
            delegate?.didFind(Array(discoveredDevices))
        }
    }
    
    func registerServices() {
        ConnectSDKWrapper.platforms.forEach { platformClassName, discoveryProviderClassName in
            if let platformClass = NSClassFromString(platformClassName) as? NSObject.Type,
               let discoveryProviderClass = NSClassFromString(discoveryProviderClassName) as? DiscoveryProvider.Type {
                discoveryManager.registerDeviceService(platformClass, withDiscovery: discoveryProviderClass)
            } else if (platformClassName == Platform.smartview.rawValue) {
                // Initialize and start SmartView service search
                serviceSearch = Service.search()
                serviceSearch?.delegate = self
            }
        }
    }
    
    func unregisterServices() {
        ConnectSDKWrapper.platforms.forEach { platformClassName, discoveryProviderClassName in
            if let platformClass = NSClassFromString(platformClassName) as? NSObject.Type,
               let discoveryProviderClass = NSClassFromString(discoveryProviderClassName) as? DiscoveryProvider.Type {
                discoveryManager.unregisterDeviceService(platformClass, withDiscovery: discoveryProviderClass)
            } else if (platformClassName == Platform.smartview.rawValue) {
                serviceSearch = nil
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
