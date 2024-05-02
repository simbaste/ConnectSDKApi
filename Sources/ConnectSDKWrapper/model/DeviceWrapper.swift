//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//

import Foundation
import ConnectSDK

/**
 A wrapper for a ConnectSDK ConnectableDevice.
 */
public class DeviceWrapper: NSObject, ConnectableDeviceDelegate {
    
    /// The underlying ConnectSDK ConnectableDevice.
    private let device: ConnectableDevice!
    
    /// The browser session associated with the device.
    private var browserSession: LaunchSession? = nil
    
    /// An optional fake device for testing purposes.
    private let fakeDevice: FakeDevice?
    
    /// The delegate for handling device events.
    public var delegate: ConnectableDeviceWrapperDelegate? = nil
    
    /// Object to control media player
    var launchObject: MediaLaunchObject?
    
    /**
     Initializes a new DeviceWrapper with the specified ConnectableDevice.
     
     - Parameters:
       - device: The ConnectableDevice to wrap.
       - fakeDevice: An optional FakeDevice for testing purposes.
     */
    public init(_ device: ConnectableDevice?, _ fakeDevice: FakeDevice? = nil) {
        self.device = device
        self.fakeDevice = fakeDevice
        super.init()
        device?.delegate = self
    }
    
    /// The name of the device.
    public var name: String? {
        return device?.friendlyName ?? fakeDevice?.name
    }
    
    /// The capabilities of the device.
    public var capabilities: [LauncherCapability] {
        return device.capabilities
            .compactMap { $0 as? String }
            .compactMap { LauncherCapability(rawValue: $0) }
    }
    
    /// The services provided by the device.
    public var services: [DeviceServiceWrapper] {
        return device.services
            .compactMap { $0 as? DeviceService }
            .map { DeviceServiceWrapper($0) }
    }
    
    /// The address of the device.
    private var address: String? {
        return device?.address
    }
    
    /// Indicates whether the device is connected.
    public var isConnected: Bool {
        return device?.connected ?? fakeDevice?.isConnected ?? false
    }
    
    // MARK: - Functions
    
    /**
     Checks if the device has the specified capability.
     
     - Parameter capability: The capability to check.
     - Returns: `true` if the device has the capability, otherwise `false`.
     */
    public func hasCapability(_ capability: LauncherCapability) -> Bool {
        return device.hasCapability(capability.rawValue)
    }
    
    public func hasCapability(_ capability: String) -> Bool {
        return device.hasCapability(capability)
    }
    
    /**
     Checks if the device has all of the specified capabilities.
     
     - Parameter capabilities: The capabilities to check.
     - Returns: `true` if the device has all of the capabilities, otherwise `false`.
     */
    public func hasCapabilities(_ capabilities: [LauncherCapability]) -> Bool {
        return capabilities.allSatisfy { hasCapability($0) }
    }
    
    /**
     Checks if the device has the specified media control capability.
     
     - Parameter capability: The media control capability to check.
     - Returns: `true` if the device has the capability, otherwise `false`.
     */
    public func hasCapability(_ capability: MediaControl) -> Bool {
        return device.services.contains { service in
            if let deviceService = service as? DeviceService {
                deviceService.hasCapability(capability.rawValue)
            }
            return false
        }
    }
    
    /**
     Checks if the device has all of the specified media control capabilities.
     
     - Parameter capabilities: The media control capabilities to check.
     - Returns: `true` if the device has all of the capabilities, otherwise `false`.
     */
    public func hasCapabilities(_ capabilities: [MediaControl]) -> Bool {
        return capabilities.allSatisfy { hasCapability($0) }
    }
    
    /**
     Checks if the device has the specified volume control capability.
     
     - Parameter capability: The volume control capability to check.
     - Returns: `true` if the device has the capability, otherwise `false`.
     */
    public func hasCapability(_ capability: VolumeControl) -> Bool {
        return device.services.contains { service in
            if let deviceService = service as? DeviceService {
                deviceService.hasCapability(capability.rawValue)
            }
            return false
        }
    }
    
    /**
     Checks if the device has all of the specified volume control capabilities.
     
     - Parameter capabilities: The volume control capabilities to check.
     - Returns: `true` if the device has all of the capabilities, otherwise `false`.
     */
    public func hasCapabilities(_ capabilities: [VolumeControl]) -> Bool {
        return capabilities.allSatisfy { hasCapability($0) }
    }
    
    /// Connects to the device.
    public func connect() {
        device?.connect()
    }
    
    /// Disconnects from the device.
    public func disconnect() {
        device?.disconnect()
    }
    
    /**
     Opens a browser on the device with the specified URL.
     
     - Parameters:
       - urlString: The URL string to open in the browser.
       - success: A closure to be called upon successful launch, taking an optional LaunchSession as its parameter.
       - failure: A closure to be called upon failure, taking an optional Error as its parameter.
     */
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
                }
                success(session)
            }, failure: { error in
                failure(error)
            })
            
        } else {
            let error = NSError(domain: "com.netgem", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string: \(urlString)"])
            failure(error)
        }
    }
    
    /**
     Closes the browser session.
     
     - Parameters:
       - success: A closure to be called upon successful closure, taking an optional Any as its parameter.
       - failure: A closure to be called upon failure, taking an optional Error as its parameter.
     */
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
    
    /**
     Sets the mute state of the device.
     
     - Parameters:
       - mute: The desired mute state (`true` for mute, `false` for unmute).
       - success: A closure to be called upon success, taking an optional Any as its parameter.
       - failure: A closure to be called upon failure, taking an optional Error as its parameter.
     */
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
    
    /**
     Sets the volume level of the device.
     
     - Parameters:
       - volume: The desired volume level.
       - success: A closure to be called upon success, taking an optional Any as its parameter.
       - failure: A closure to be called upon failure, taking an optional Error as its parameter.
     */
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
    
    /**
    Make the MediaPlayerBuilder to contigure media info to be played
     In order to start the player, call the MediaPlayerBuilder -> build() method
     */
    public func makeMediaBuilder() -> MediaPlayerBuilder {
        return MediaPlayerBuilder(device: self)
    }
    
    /**
     Play a media
     
     - Parameters:
       - mediaInfo: The media to play.
       - shouldLoop: Define is the media should loop.
       - success: A closure to be called upon success, taking an optional MediaLaunchObject as its parameter.
       - failure: A closure to be called upon failure, taking an optional Error as its parameter.
     */
    func playMedia(
        with mediaInfo: MediaInfo!,
        shouldLoop: Bool,
        success: @escaping (_ launchObject: MediaLaunchObject?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        device.mediaPlayer().playMedia(with: mediaInfo, shouldLoop: shouldLoop) { mediaLaunchObject in
            self.launchObject = mediaLaunchObject
            success(mediaLaunchObject)
        } failure: { error in
            failure(error)
        }
    }
    
    public func playingState(
        success: @escaping (_ state: MediaControlPlayState) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        launchObject?.mediaControl.subscribePlayState(success: { state in
            switch state {
            case MediaControlPlayStateUnknown:
                success(MediaControlPlayState.unknown)
                break
            case MediaControlPlayStateIdle:
                success(MediaControlPlayState.idle)
                break
            case MediaControlPlayStatePlaying:
                success(MediaControlPlayState.playing)
                break
            case MediaControlPlayStatePaused:
                success(MediaControlPlayState.paused)
                break
            case MediaControlPlayStateBuffering:
                success(MediaControlPlayState.buffering)
                break
            case MediaControlPlayStateFinished:
                success(MediaControlPlayState.finished)
                break
            default:
                success(MediaControlPlayState.unknown)
                break
            }
            
        }, failure: { err in
            failure(err)
        })
    }
    
    public func play(
        success: @escaping (_ succes: Any?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        launchObject?.mediaControl?.play(success: { res in
            success(res)
        }, failure: { err in
            failure(err)
        })
    }
    
    public func pause(
        success: @escaping (_ succes: Any?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        launchObject?.mediaControl?.pause(success: { res in
            success(res)
        }, failure: { err in
            failure(err)
        })
    }
    
    public func seek(
        position: TimeInterval,
        success: @escaping (_ succes: Any?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        launchObject?.mediaControl?.seek(position, success: { res in
            success(res)
        }, failure: { err in
            failure(err)
        })
    }
    
    public func closeSession(
        success: @escaping (_ succes: Any?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        launchObject?.session?.close(success: { res in
            success(res)
        }, failure: { err in
            failure(err)
        })
    }
    
    public func closeMediaPlayer(
        success: @escaping (_ succes: Any?) -> Void,
        failure: @escaping (_ error: Error?) -> Void
    ) {
        if let launchSession = launchObject?.session {
            device.mediaPlayer()?.closeMedia(launchSession, success: { res in
                success(res)
            }, failure: { err in
                failure(err)
            })
        } else {
            failure(CustomError(message: "Cannot close \(String(describing: launchObject?.session)) session"))
        }
        
    }
    
    // MARK: - Delegate
    
    /**
     Called when the device is ready.
     
     - Parameter device: The ConnectableDevice that is ready.
     */
    public func connectableDeviceReady(_ device: ConnectableDevice!) {
        delegate?.device(didConnected: DeviceWrapper(device))
    }
    
    /**
     Called when the device is disconnected.
     
     - Parameters:
       - device: The ConnectableDevice that is disconnected.
       - error: An optional Error indicating the reason for disconnection.
     */
    public func connectableDeviceDisconnected(_ device: ConnectableDevice!, withError error: (any Error)!) {
        delegate?.device(didDisconnected: DeviceWrapper(device), withError: error)
    }
    
    /**
     Called when pairing is required with a service of the device.
     
     - Parameters:
       - device: The ConnectableDevice that requires pairing.
       - service: The DeviceService that requires pairing.
       - pairingType: The type of pairing required.
       - pairingData: The data required for pairing.
     */
    public func connectableDevice(_ device: ConnectableDevice!, service: DeviceService!, pairingRequiredOfType pairingType: Int32, withData pairingData: Any!) {
        delegate?.device(DeviceWrapper(device), service: DeviceServiceWrapper(service), pairingRequiredOfType: pairingType)
    }
    
    /**
     Called when pairing with a service has failed.
     
     - Parameters:
       - device: The ConnectableDevice that failed pairing.
       - service: The DeviceService that failed pairing.
       - error: An optional Error indicating the reason for failure.
     */
    public func connectableDevice(_ device: ConnectableDevice!, service: DeviceService!, pairingFailedWithError error: (any Error)!) {
        delegate?.device(DeviceWrapper(device), service: DeviceServiceWrapper(service), pairingFailedWithError: error)
    }
    
    /**
     Called when pairing with a service has succeeded.
     
     - Parameters:
       - device: The ConnectableDevice that succeeded pairing.
       - service: The DeviceService that succeeded pairing.
     */
    public func connectableDevicePairingSuccess(_ device: ConnectableDevice!, service: DeviceService!) {
        delegate?.deviceParingSucced(_device: DeviceWrapper(device), service: DeviceServiceWrapper(service))
    }
    
    // MARK: - Comparaison between two devices

    /**
     Compares the receiver to the given object.
     
     - Parameter object: The object to compare to the receiver.
     - Returns: `true` if the receiver is equal to the object, otherwise `false`.
     */
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? DeviceWrapper else { return false }
        return self.name == other.name
    }

    /**
     Returns the hash value of the receiver.
     
     - Returns: The hash value of the receiver.
     */
    public override var hash: Int {
        return name?.hash ?? 0
    }
}

