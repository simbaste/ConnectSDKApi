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
    
    public var capabilities: [LauncherCapability] {
        return device.capabilities
            .compactMap { $0 as? String }
            .compactMap { LauncherCapability(rawValue: $0) }
    }
    
    public var services: [DeviceServiceWrapper] {
        return device.services
            .compactMap { $0 as? DeviceService }
            .map { DeviceServiceWrapper($0) }
    }
    
    private var address: String? {
        return device?.address
    }
    
    public var isConnected: Bool {
        return device?.connected ?? fakeDevice?.isConnected ?? false
    }
    
    // MARK: - Functions
    
    public func hasCapability(_ capability: LauncherCapability) -> Bool {
        return device.hasCapability(capability.rawValue)
    }
    
    public func hasCapabilities(_ capabilities: [LauncherCapability]) -> Bool {
        return capabilities.allSatisfy { hasCapability($0) }
    }
    
    public func hasCapability(_ capability: MediaControl) -> Bool {
        return device.services.contains { service in
            if let deviceService = service as? DeviceService {
                deviceService.hasCapability(capability.rawValue)
            }
            return false
        }
    }
    
    public func hasCapabilities(_ capabilities: [MediaControl]) -> Bool {
        return capabilities.allSatisfy { hasCapability($0) }
    }
    
    public func hasCapability(_ capability: VolumeControl) -> Bool {
        return device.services.contains { service in
            if let deviceService = service as? DeviceService {
                deviceService.hasCapability(capability.rawValue)
            }
            return false
        }
    }
    
    public func hasCapabilities(_ capabilities: [VolumeControl]) -> Bool {
        return capabilities.allSatisfy { hasCapability($0) }
    }
    
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
                if (self.hasCapability(.appClose)) {
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
    
    public func setMute(
        mute: Bool,
        success: @escaping (_ launchSession: Any?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        if (hasCapability(.volumeSet)) {
            device.volumeControl().setMute(mute) { res in
                success(res)
            } failure: { err in
                failure(err)
            }
        } else {
            failure(CustomError(message: "Device doesn't have volume set control capability"))
        }
    }
    
    public func setVolume(
        volume: Float,
        success: @escaping (_ launchSession: Any?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        if (hasCapability(.volumeUpDown)) {
            device.volumeControl().setVolume(volume) { res in
                success(res)
            } failure: { err in
                failure(err)
            }
        } else {
            failure(CustomError(message: "Device doesn't have volume upDown control capability"))
        }
    }
    
    // MARK: - Delegate
    
    public func connectableDeviceReady(_ device: ConnectableDevice!) {
        delegate?.device(didConnected: DeviceWrapper(device))
    }
    
    public func connectableDeviceDisconnected(_ device: ConnectableDevice!, withError error: (any Error)!) {
        delegate?.device(didDisconnected: DeviceWrapper(device), withError: error)
    }
    
    /**
     * Called after connect function is called and pairing is required
     */
    public func connectableDevice(_ device: ConnectableDevice!, service: DeviceService!, pairingRequiredOfType pairingType: Int32, withData pairingData: Any!) {
        delegate?.device(DeviceWrapper(device), service: DeviceServiceWrapper(service), pairingRequiredOfType: pairingType)
    }
    
    /**
     * Called when paraing has failed
     */
    public func connectableDevice(_ device: ConnectableDevice!, service: DeviceService!, pairingFailedWithError error: (any Error)!) {
        delegate?.device(DeviceWrapper(device), service: DeviceServiceWrapper(service), pairingFailedWithError: error)
    }
    
    /**
     * Called when the connection has succed after pairing
     */
    public func connectableDevicePairingSuccess(_ device: ConnectableDevice!, service: DeviceService!) {
        delegate?.deviceParingSucced(_device: DeviceWrapper(device), service: DeviceServiceWrapper(service))
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

