//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//

import Foundation
import ConnectSDK

public class DeviceWrapper: NSObject, ConnectableDeviceDelegate {

    private let device: ConnectableDevice
    public var delegate: ConnectableDeviceWrapperDelegate? = nil

    init(device: ConnectableDevice) {
        self.device = device
        super.init()
        device.delegate = self
    }
    
    public var name: String {
        return device.friendlyName
    }
    
    public override var description: String {
        return device.description
    }
    
    var isConnected: Bool {
        return device.connected
    }
    
    // MARK: - Functions
    
    public func connect() {
        device.connect()
    }
    
    public func disconnect() {
        device.disconnect()
    }
    
    // MARK: - Delegate
    
    public func connectableDeviceReady(_ device: ConnectableDevice!) {
        delegate?.device(didConnected: DeviceWrapper(device: device))
    }
    
    public func connectableDeviceDisconnected(_ device: ConnectableDevice!, withError error: (any Error)!) {
        delegate?.device(didDisconnected: DeviceWrapper(device: device), withError: error)
    }
    
}
