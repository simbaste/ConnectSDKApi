// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ConnectSDK

/**
 A wrapper for the ConnectSDK DiscoveryManager.
 */
public class ConnectSDKWrapper: NSObject, DiscoveryManagerDelegate {
    /// The delegate for handling discovery events.
    public weak var delegate: DiscoveryManagerWrapperDelegate?
    
    /// The underlying ConnectSDK DiscoveryManager.
    private let discovereyManager: DiscoveryManager
    
    /// The set of discovered devices.
    private var discoveredDevices: Set<DeviceWrapper> = Set()
    
    /**
     Initializes a new ConnectSDKWrapper.
     */
    public override init() {
        discovereyManager = DiscoveryManager.shared()
        super.init()
        discovereyManager.delegate = self
        AirPlayService.setAirPlayServiceMode(AirPlayServiceModeMedia)
        DIALService.registerApp("Levak")
    }
    
    /**
     Starts searching for devices.
     */
    public func searchForDevices() {
        self.discoveredDevices.removeAll()
        discovereyManager.pairingLevel = DeviceServicePairingLevelOn
        discovereyManager.registerDefaultServices()
        self.discovereyManager.startDiscovery()
    }
    
    /**
     Stops searching for devices.
     */
    public func stopSearchingForDevices() {
        self.discovereyManager.stopDiscovery()
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
