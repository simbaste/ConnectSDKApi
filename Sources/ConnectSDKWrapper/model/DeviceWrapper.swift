//
//  DeviceWrapper.swift
//  
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//

import Foundation
import ConnectSDK
import SmartView

/**
 A wrapper for a ConnectSDK ConnectableDevice.
 */
public class DeviceWrapper: NSObject, ConnectableDeviceDelegate {
    
    /// The underlying ConnectSDK ConnectableDevice.
    private var device: ConnectableDevice!
    
    /// The underlying SmartView Service.
    var smartViewService: Service!
    
    /// The underlying SmartView application
    private var smartViewApplication: Application!
    
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
    
    /**
     Initializes a new DeviceWrapper with the specified SmartView Service
     - Parameters:
        - service: The SmartView Service to wrap
     */
    public init(service: Service, _ fakeDevice: FakeDevice? = nil) {
        self.smartViewService = service
        self.fakeDevice = fakeDevice
        super.init()
    }
    
    /// The device ID
    public var id: String? {
        return device?.id
    }
    
    public var type: DeviceWrapperType {
        if device != nil {
            return .webos
        } else if smartViewService != nil {
            return .smartview
        } else {
            return .unknown
        }
    }
    
    /// The name of the device.
    public var name: String? {
        return device?.friendlyName ?? smartViewService?.name ?? fakeDevice?.name
    }
    
    /// The modelName of the device
    public var modelName: String? {
        return device?.modelName ?? smartViewService?.name
    }
    
    /// The capabilities of the device.
    public var capabilities: [LauncherCapability] {
        return device?.capabilities
            .compactMap { $0 as? String }
            .compactMap { LauncherCapability(rawValue: $0) } ?? []
    }
    
    /// The services provided by the device.
    public var services: [DeviceServiceWrapper] {
        return device?.services
            .compactMap { $0 as? DeviceService }
            .map { DeviceServiceWrapper($0) } ?? []
    }
    
    /// The address of the device.
    public var ipAddress: String? {
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
    public func connect(appId: NSURL, channelID: String) throws {
        if (smartViewService != nil) {
            try connectToSmartView(appId, channelID)
        } else if (device != nil) {
            device?.connect()
        } else {
            throw CustomError(message: "Not define", code: 500)
        }
    }
    
    public func connect() throws {
        if (device != nil) {
            device?.connect()
        } else {
            throw CustomError(message: "Not define", code: 500)
        }
    }
    
    private func connectToLG() {
        device?.connect()
    }
    
    private func getApplicationInfo(
        application: Application,
        completion: @escaping (ApplicationInfo) -> Void
    ) {
        application.getInfo({ info, error in
            if let error = error, error.code == 404 {
                // Install the application on the TV
                // Note: Thos will only bring up the installation page on the TV
                // The user will still have to acknowledge by selecting "install" using the TV remmote.
                application.install({ success, error in
                    if let error = error {
//                        self.delegate?.didFailToPair(device: self, service: DeviceServiceWrapper(self.smartViewService!), withError: error)
                        completion(.failedParing(error: error))
                    } else {
//                        self.delegate?.didRequirePairing(ofType: 101, with: self, service: DeviceServiceWrapper(self.smartViewService!))
                        completion(.needParing)
                    }
                })
            } else if let error = error {
                completion(.retrievedInfoFailed(error: error))
            } else {
                print("application info = \(String(describing: info))")
                completion(.retrievedInfo(info: info))
            }
        })
    }
    
    private func connectToSmartViewApplication(
        _ application: Application,
        startArgs: [String: String]? = nil,
        completion: ((Result<ApplicationState, Error>) -> Void)? = nil
    ) {
        print("application isConnected ==> \(String(describing: application.isConnected))")
        application.connect(startArgs) { client, error in
            if let error = error, error.code == 404 {
                // Install the application on the TV
                // Note: Thos will only bring up the installation page on the TV
                // The user will still have to acknowledge by selecting "install" using the TV remmote.
                application.install({ success, error in
                    if let error = error {
                        self.delegate?.didFailToPair(device: self, service: DeviceServiceWrapper(self.smartViewService!), withError: error)
                    } else {
                        self.delegate?.didRequirePairing(ofType: 101, with: self, service: DeviceServiceWrapper(self.smartViewService!))
                    }
                })
            } else if let error = error {
                self.delegate?.didFailToPair(device: self, service: DeviceServiceWrapper(self.smartViewService!), withError: error)
            } else {
                if let completion = completion {
                    completion(.success(.communicate))
                } else {
                    self.delegate?.didConnect(device: self)
                }
            }
        }
    }
    
    private func getSmartViewApp(_ appId: NSURL, _ channelID: String, startArgs: [String: String] = [:]) throws -> Application {
        if smartViewApplication?.uri != appId.absoluteString {
            
            do {
                let data = try JSONSerialization.data(withJSONObject: startArgs, options: .prettyPrinted)
                let args: [String: AnyObject] = [
                    "id": String(data: data, encoding: .utf8) as AnyObject
                ]
                smartViewApplication = smartViewService.createApplication(appId, channelURI: channelID, args: args)
            } catch {
                throw CustomError(message: "Invalid arguments", code: 422)
            }
        }
        guard let application = smartViewApplication else {
            throw CustomError(message: "Cannot create SmartView application", code: 404)
        }
        
        return application
    }
    
    private func connectToSmartView(_ appId: NSURL, _ channelID: String, startArgs: [String: String] = [:]) throws {
        print("connectToSmartView with appId ==> \(String(describing: appId))")
        
        let application = try getSmartViewApp(appId, channelID, startArgs: startArgs)
        getApplicationInfo(application: application) { appInfo in
            switch appInfo {
            case .needParing:
                self.delegate?.didRequirePairing(ofType: 101, with: self, service: DeviceServiceWrapper(self.smartViewService!))
            case .failedParing(error: let error):
                self.delegate?.didFailToPair(device: self, service: DeviceServiceWrapper(self.smartViewService!), withError: error)
            case .retrievedInfo(info: let info):
                if let isRunning = info?["running"] as? Decimal, isRunning == 0 {
                    // Send message to applicarion
                    self.connectToSmartViewApplication(application, startArgs: startArgs)
                } else {
                    self.connectToSmartViewApplication(application, startArgs: startArgs)
                }
            case .retrievedInfoFailed(error: let error):
                self.delegate?.didFailToPair(device: self, service: DeviceServiceWrapper(self.smartViewService!), withError: error)
            }
        }
    }
    
    /// Disconnects from the device.
    public func disconnect() {
        device?.disconnect()
        smartViewApplication?.disconnect({ client, error in
            if client != nil {
                self.delegate?.didDisconnect(device: self, withError: error)
            }
        })
    }
    
    /**
     Opens a browser on the device with the specified URL.
     
     - Parameters:
       - urlString: The URL string to open in the browser.
       - completion: A closure to be called upon successful launch, taking a result containing either a LaunchSession or an Error.
     */
    @available(*, deprecated, message: "Use launchGame() instead.")
    public func openBrowser(
        with urlString: String,
        completion: @escaping (Result<ApplicationState, Error>) -> Void
    ) {
        guard let url = URL(string: urlString), let launcher = device?.launcher() else {
            let error = NSError(domain: "com.netgem", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string: \(urlString)"])
            completion(.failure(error))
            return
        }
        
        launcher.launchBrowser(url, success: { session in
            if self.hasCapability(.appClose) {
                self.browserSession = session
            }
            completion(.success(.lauched))
        }, failure: { error in
            completion(.failure(error ?? CustomError(message: "Can't open browser", code: 403)))
        })
    }
    
    /**
     Launch a smartView application on the device
     - Parameters:
        - companionAppUrl: The companion App url
        - appId: The ID of the application to launch.
        - channelIdURI: The channel URL for the application.
        - args: Otional arguments for teh application.
        - completion: A closure to be called upon success, taking a result containing either a Bool or an Error.
     */
    public func launchGame(
        companionAppUrl: String,
        appId: NSURL,
        channelID: String,
        args: [String: String],
        completion: @escaping (Result<ApplicationState, Error>) -> Void
    ) {
        if device != nil {
            var urlComponents = URLComponents(string: companionAppUrl)
            var queryItems = [URLQueryItem]()
            for (key, value) in args {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents?.queryItems = queryItems
            guard let urlString = urlComponents?.url?.absoluteString else {
                completion(.failure(CustomError(message: "Invalid URL", code: 422)))
                return
            }
            openBrowser(with: urlString, completion: completion)
        } else if smartViewService != nil {
            launchSmartViewGame(appId: appId, channelID: channelID, args: args, completion: completion)
        }
    }
    
    private func sendMessageToSmartViewApp(
        application: Application,
        args: [String: String],
        completion: @escaping (Result<ApplicationState, Error>) -> Void
    ) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: args)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let anyObject: AnyObject = jsonString as AnyObject
                application.publish(event: "play", message: anyObject)
                completion(.success(.communicate))
            } else {
                completion(.failure(CustomError(message: "Failed to format arguments", code: 422)))
            }
        } catch {
            completion(.failure(CustomError(message: "Failed to send message to TV", code: 502)))
        }
    }
    
    /**
     Launch a smartView application on the device
     - Parameters:
        - appId: The ID of the application to launch.
        - channelIdURI: The channel URL for the application.
        - args: Otional arguments for teh application.
        - completion: A closure to be called upon success, taking a result containing either a Bool or an Error.
     */
    @available(*, deprecated, message: "Use launchGame() instead")
    public func launchSmartViewGame(
        appId: NSURL,
        channelID: String,
        args: [String: String],
        completion: @escaping (Result<ApplicationState, Error>) -> Void
    ) {
        guard smartViewService != nil else {
            let error = NSError(domain: "com.netgem", code: 1001, userInfo: [NSLocalizedDescriptionKey: "SmartView service not available"])
            completion(.failure(error))
            return
        }
        
        do {
            let application = try getSmartViewApp(appId, channelID, startArgs: args)
            getApplicationInfo(application: application) { appInfo in
                switch appInfo {
                case .needParing:
                    completion(.success(.needConnection))
                case .failedParing(error: let error):
                    completion(.failure(error))
                case .retrievedInfo(info: _):
                    print("application isConnected ==> \(String(describing: application.isConnected))")
                    if (application.isConnected) {
                        self.sendMessageToSmartViewApp(application: application, args: args, completion: completion)
                    } else {
                        self.connectToSmartViewApplication(application, startArgs: args)
                    }
                case .retrievedInfoFailed(error: let error):
                    self.delegate?.didFailToPair(device: self, service: DeviceServiceWrapper(self.smartViewService!), withError: error)
                }
            }
        } catch let error {
            completion(.failure(error))
        }
        
    }

    /**
     Closes the browser session.
     
     - Parameter completion: A closure to be called upon successful closure, taking a result containing either Any or an Error.
     */
    public func closeBrowser(
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        self.browserSession?.close(success: { res in
            completion(.success(res))
        }, failure: { err in
            completion(.failure(err ?? CustomError(message: "Can't clode browser", code: 500)))
        })
    }
    
    /**
     Closes the game companion app.
     
     - Parameter completion: A closure to be called upon successful closure, taking a result containing either Any or an Error.
     */
    public func closeGame(
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        self.browserSession?.close(success: { res in
            completion(.success(res))
        }, failure: { err in
            completion(.failure(err ?? CustomError(message: "Can't clode browser", code: 500)))
        })
        self.smartViewApplication?.stop({ success, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(success))
            }
        })
    }

    /**
     Sets the mute state of the device.
     
     - Parameters:
       - mute: The desired mute state (`true` for mute, `false` for unmute).
       - completion: A closure to be called upon success, taking a result containing either Any or an Error.
     */
    public func setMute(
        mute: Bool,
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        guard hasCapability(.muteSet) else {
            let error = CustomError(message: "Device doesn't have volume set control capability", code: 505)
            completion(.failure(error))
            return
        }
        
        device.volumeControl().setMute(mute) { res in
            completion(.success(res))
        } failure: { err in
            completion(.failure(err ?? CustomError(message: "Can't mute device", code: 505)))
        }
    }

    /**
     Sets the volume level of the device.
     
     - Parameters:
       - volume: The desired volume level.
       - completion: A closure to be called upon success, taking a result containing either Any or an Error.
     */
    public func setVolume(
        volume: Float,
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        guard hasCapability(.volumeSet) else {
            let error = CustomError(message: "Device doesn't have volume upDown control capability", code: 505)
            completion(.failure(error))
            return
        }
        
        device.volumeControl().setVolume(volume) { res in
            completion(.success(res))
        } failure: { err in
            completion(.failure(err ?? CustomError(message: "Can't set the volume", code: 505)))
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
       - shouldLoop: Define if the media should loop.
       - completion: A closure to be called upon success, taking a result containing either a MediaLaunchObject or an Error.
     */
    func playMedia(
        with mediaInfo: MediaInfo?,
        shouldLoop: Bool,
        completion: @escaping (Result<MediaLaunchObject?, Error>) -> Void
    ) {
        guard let mediaPlayer = device?.mediaPlayer() else {
            let error = CustomError(message: "Media player not available", code: 505)
            completion(.failure(error))
            return
        }
        
        mediaPlayer.playMedia(with: mediaInfo, shouldLoop: shouldLoop) { mediaLaunchObject in
            self.launchObject = mediaLaunchObject
            completion(.success(mediaLaunchObject))
        } failure: { error in
            completion(.failure(error ?? CustomError(message: "Can't play media", code: 505)))
        }
    }

    
    /**
     Get the device playing state

     - Parameters:
      - completion: The closure which is called when we get the device playing state or when an error occurs.
     */
    public func playingState(completion: @escaping (Result<MediaControlPlayState, Error>) -> Void) {
        if let mediaControl = launchObject?.mediaControl {
            mediaControl.subscribePlayState(success: { state in
                switch state {
                case MediaControlPlayStateUnknown:
                    completion(.success(.unknown))
                case MediaControlPlayStateIdle:
                    completion(.success(.idle))
                case MediaControlPlayStatePlaying:
                    completion(.success(.playing))
                case MediaControlPlayStatePaused:
                    completion(.success(.paused))
                case MediaControlPlayStateBuffering:
                    completion(.success(.buffering))
                case MediaControlPlayStateFinished:
                    completion(.success(.finished))
                default:
                    completion(.success(.unknown))
                    break
                }
            }, failure: { error in
                completion(.failure(error ?? CustomError(message: "Can't get playing state on media control", code: 505)))
            })
        } else {
            let error = CustomError(message: "Can't get playing state on \(String(describing: launchObject?.mediaControl)) media control", code: 505)
            completion(.failure(error))
        }
    }

    
    /**
     Play the current media

     - Parameters:
      - completion: The closure which is called when the media is correctly played or when an error occurs.
     */
    public func play(completion: @escaping (Result<Any?, Error>) -> Void) {
        if let mediaControl = launchObject?.mediaControl {
            mediaControl.play(success: { result in
                completion(.success(result))
            }, failure: { error in
                completion(.failure(error ?? CustomError(message: "Can't play media control", code: 505)))
            })
        } else {
            let error = CustomError(message: "Can't play \(String(describing: launchObject?.mediaControl)) media control", code: 505)
            completion(.failure(error))
        }
    }

    
    /**
     Pause the current media

     - Parameters:
      - completion: The closure which is called when the media is correctly paused or when an error occurs.
     */
    public func pause(completion: @escaping (Result<Any?, Error>) -> Void) {
        if let mediaControl = launchObject?.mediaControl {
            mediaControl.pause(success: { res in
                completion(.success(res))
            }, failure: { error in
                completion(.failure(error ?? CustomError(message: "Can't pause media control", code: 505)))
            })
        } else {
            let error = CustomError(message: "Can't pause \(String(describing: launchObject?.mediaControl)) media control", code: 505)
            completion(.failure(error))
        }
    }

    
    /**
     Seek the current media
     
     - Parameters:
      - completion: The closure which is called when the media is correcly seeked
     */
    public func seek(
        position: TimeInterval,
        completion: @escaping (Result<Any?, Error>) -> Void
    ) {
        if let mediaControl = launchObject?.mediaControl {
            mediaControl.seek(position, success: { res in
                completion(.success(res))
            }, failure: { err in
                completion(.failure(err ?? CustomError(message: "Can't seek media control", code: 505)))
            })
        } else {
            let error = CustomError(message: "Can't seek \(String(describing: launchObject?.mediaControl)) media control", code: 505)
            completion(.failure(error))
        }
    }
    
    /**
     Close the current session
     
     - Parameters:
      - completion: The closure which is called when the session is correctly closed or when an error occurs.
     */
    public func closeSession(completion: @escaping (Result<Any?, Error>) -> Void) {
        if let session = launchObject?.session {
            session.close(success: { res in
                completion(.success(res))
            }, failure: { error in
                completion(.failure(error ?? CustomError(message: "Cannot close session", code: 505)))
            })
        } else {
            let error = CustomError(message: "Cannot close \(String(describing: launchObject?.session)) session", code: 505)
            completion(.failure(error))
        }
    }

    
    /**
     Close the current media player

     - Parameters:
      - completion: The closure which is called when the media player is correctly closed or when an error occurs.
     */
    public func closeMediaPlayer(completion: @escaping (Result<Any?, Error>) -> Void) {
        if let launchSession = launchObject?.session {
            device.mediaPlayer()?.closeMedia(launchSession, success: { res in
                completion(.success(res))
            }, failure: { error in
                completion(.failure(error ?? CustomError(message: "Cannot close session", code: 505)))
            })
        } else {
            let error = CustomError(message: "Cannot close \(String(describing: launchObject?.session)) session", code: 505)
            completion(.failure(error))
        }
    }

    
    // MARK: - Delegate
    
    /**
     Called when the device is ready.
     
     - Parameter device: The ConnectableDevice that is ready.
     */
    public func connectableDeviceReady(_ device: ConnectableDevice!) {
        self.device = device
        delegate?.didConnect(device: self)
    }
    
    /**
     Called when the device is disconnected.
     
     - Parameters:
       - device: The ConnectableDevice that is disconnected.
       - error: An optional Error indicating the reason for disconnection.
     */
    public func connectableDeviceDisconnected(_ device: ConnectableDevice!, withError error: (any Error)!) {
        self.device = device
        delegate?.didDisconnect(device: self, withError: error)
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
        self.device = device
        delegate?.didRequirePairing(ofType: pairingType, with: self, service: DeviceServiceWrapper(service))
    }
    
    /**
     Called when pairing with a service has failed.
     
     - Parameters:
       - device: The ConnectableDevice that failed pairing.
       - service: The DeviceService that failed pairing.
       - error: An optional Error indicating the reason for failure.
     */
    public func connectableDevice(_ device: ConnectableDevice!, service: DeviceService!, pairingFailedWithError error: (any Error)!) {
        self.device = device
        delegate?.didFailToPair(device: self, service: DeviceServiceWrapper(service), withError: error)
    }
    
    /**
     Called when pairing with a service has succeeded.
     
     - Parameters:
       - device: The ConnectableDevice that succeeded pairing.
       - service: The DeviceService that succeeded pairing.
     */
    public func connectableDevicePairingSuccess(_ device: ConnectableDevice!, service: DeviceService!) {
        self.device = device
        delegate?.didPair(device: self, service: DeviceServiceWrapper(service))
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

