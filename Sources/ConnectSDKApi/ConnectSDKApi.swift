// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import ConnectSDK

public class ConnectSDKApi: NSObject,
    ConnectableDeviceDelegate,
    DiscoveryManagerDelegate {
    
    
    public weak var delegate: ConnectSDKDelegate?
    private let discovereyManager: DiscoveryManager
    private var discoveredDevices: [ConnectableDevice] = []
    
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
        discoveredDevices.append(device)
        delegate?.didFindDevices(discoveredDevices)
    }
    
    public func discoveryManager(_ manager: DiscoveryManager!, didLose device: ConnectableDevice!) {
        // Retirer l'appareil perdu de la liste des appareils découverts
        if let index = discoveredDevices.firstIndex(of: device) {
            discoveredDevices.remove(at: index)
        }
        delegate?.didFindDevices(discoveredDevices)
    }
    
    public func connectableDeviceReady(_ device: ConnectableDevice!) {
        delegate?.device(didConnected: device)
    }
    
    public func connectableDeviceDisconnected(_ device: ConnectableDevice!, withError error: (any Error)!) {
        delegate?.device(didDisconnected: device, withError: error)
    }
    
    
}
