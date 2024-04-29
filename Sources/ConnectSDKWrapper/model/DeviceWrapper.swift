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
    private var browserSession: LaunchSession? = nil
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
    
    private var address: String? {
        return device?.address
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
    
    public func openBrowser(
        with urlString: String,
        success: @escaping (_ launchSession: LaunchSession?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
            
        if let url = URL(string: urlString),
           let launcher = device?.launcher() {
            
            launcher.launchBrowser(url, success: { session in
                print("google opened ")
                if self.device.hasCapability(kLauncherAppClose) {
                    self.browserSession = session
                    success(session)
                }
            }, failure: { error in
                failure(error)
            })
            
        } else {
            let error = NSError(domain: "com.netgem", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string: \(urlString)"])
            failure(error)
        }
    }
    
    public func closeBrowser(
        success: @escaping (_ res: Any?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        self.browserSession?.close(success: { res in
            success(res)
        }, failure: { err in
            failure(err)
        })
    }
    
    // MARK: - Delegate
    
    public func connectableDeviceReady(_ device: ConnectableDevice!) {
        delegate?.device(didConnected: DeviceWrapper(device))
    }
    
    public func connectableDeviceDisconnected(_ device: ConnectableDevice!, withError error: (any Error)!) {
        delegate?.device(didDisconnected: DeviceWrapper(device), withError: error)
    }
    
    // MARK: - Comparaison between two devices
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DeviceWrapper else { return false }
        return self.name == other.name
    }

    public override var hash: Int {
        return name?.hash ?? 0
    }
    
}

