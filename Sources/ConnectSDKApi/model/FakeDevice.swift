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
}
