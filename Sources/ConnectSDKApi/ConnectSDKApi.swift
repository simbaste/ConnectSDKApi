// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ConnectSDK

public class ConnectSDKApi: NSObject,
    ConnectableDeviceDelegate,
    DiscoveryManagerDelegate {
    
    
    public weak var delegate: ConnectSDKDelegate?
    private let discovereyManager: DiscoveryManager
    private var discoveredDevices: Set<ConnectableDevice> = Set()
    
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
        discoveredDevices.insert(device)
        delegate?.didFindDevices(Array(discoveredDevices))
    }
    
    public func discoveryManager(_ manager: DiscoveryManager!, didLose device: ConnectableDevice!) {
        discoveredDevices.remove(device)
        delegate?.didFindDevices(Array(discoveredDevices))
    }
    
    public func discoveryManager(_ manager: DiscoveryManager!, didUpdate device: ConnectableDevice!) {
        discoveredDevices.update(with: device)
        delegate?.didFindDevices(Array(discoveredDevices))
    }
    
    public func connectableDeviceReady(_ device: ConnectableDevice!) {
        delegate?.device(didConnected: device)
    }
    
    public func connectableDeviceDisconnected(_ device: ConnectableDevice!, withError error: (any Error)!) {
        delegate?.device(didDisconnected: device, withError: error)
    }
    
    
}
