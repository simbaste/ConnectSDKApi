// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ConnectSDK

public class ConnectSDKWrapper: NSObject,
    DiscoveryManagerDelegate {
    
    public weak var delegate: DiscoveryManagerWrapperDelegate?
    private let discovereyManager: DiscoveryManager
    private var discoveredDevices: Set<DeviceWrapper> = Set()
    
    public override init() {
        discovereyManager = DiscoveryManager.shared()
        super.init()
        discovereyManager.delegate = self
        AirPlayService.setAirPlayServiceMode(AirPlayServiceModeMedia)
        DIALService.registerApp("Levak")
    }
    
    public func searchForDevices() {
        self.discoveredDevices.removeAll()
        discovereyManager.pairingLevel = DeviceServicePairingLevelOn
        discovereyManager.registerDefaultServices()
        self.discovereyManager.startDiscovery()
    }
    
    public func discoveryManager(_ manager: DiscoveryManager!, didFind device: ConnectableDevice!) {
        discoveredDevices.insert(DeviceWrapper(device: device))
        delegate?.didFind(Array(discoveredDevices))
    }
    
    public func discoveryManager(_ manager: DiscoveryManager!, didLose device: ConnectableDevice!) {
        discoveredDevices.remove(DeviceWrapper(device: device))
        delegate?.didFind(Array(discoveredDevices))
    }
    
    public func discoveryManager(_ manager: DiscoveryManager!, didUpdate device: ConnectableDevice!) {
        discoveredDevices.update(with: DeviceWrapper(device: device))
        delegate?.didFind(Array(discoveredDevices))
    }
    
}
