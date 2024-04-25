//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//

import Foundation
import ConnectSDK

public class DeviceWrapper: NSObject, ConnectableDeviceDelegate {

    private let device: ConnectableDevice!
    private let fakeDevice: FakeDevice?
    public var delegate: ConnectableDeviceWrapperDelegate? = nil

    public init(_ device: ConnectableDevice?, _ fakeDevice: FakeDevice? = nil) {
        self.device = device
        self.fakeDevice = fakeDevice
        super.init()
        device?.delegate = self
    }
    
    public var name: String? {
        return device?.friendlyName ?? fakeDevice?.name
    }
    
    public override var description: String {
        return device?.description ?? fakeDevice?.description ?? super.description
    }
    
    public var isConnected: Bool {
        return device?.connected ?? fakeDevice?.isConnected ?? false
    }
    
    // MARK: - Functions
    
    public func connect() {
        device?.connect()
    }
    
    public func disconnect() {
        device?.disconnect()
    }
    
    // MARK: - Delegate
    
    public func connectableDeviceReady(_ device: ConnectableDevice!) {
        delegate?.device(didConnected: DeviceWrapper(device))
    }
    
    public func connectableDeviceDisconnected(_ device: ConnectableDevice!, withError error: (any Error)!) {
        delegate?.device(didDisconnected: DeviceWrapper(device), withError: error)
    }
    
}
