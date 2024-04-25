//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 24/04/2024.
//

import Foundation
import ConnectSDK

public protocol DiscoveryManagerWrapperDelegate: AnyObject {
    func didFind(_ devices: [DeviceWrapper])
    func didFail(with error: Error)
    
}
