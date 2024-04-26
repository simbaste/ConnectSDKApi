//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//

public struct FakeDevice {
    var name: String
    var description: String
    var isConnected: Bool
    weak var delegate: ConnectableDeviceWrapperDelegate?
    
    public init(name: String, description: String, isConnected: Bool, delegate: ConnectableDeviceWrapperDelegate? = nil) {
        self.name = name
        self.description = description
        self.isConnected = isConnected
        self.delegate = delegate
    }
}
