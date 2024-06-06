```markdown
# ConnectSDKWrapper

ConnectSDKWrapper is a Swift package that provides a wrapper around the LG WebOS ConnectSDK, allowing you to easily integrate LG WebOS devices into your iOS applications.

## Installation

You can install ConnectSDKWrapper via Swift Package Manager. Add the following URL to your Xcode project's Swift Packages tab:

```plaintext
git@bitbucket.org:netgem/connectsdkwrapper-ios.git
```

Or use the HTTPS URL:

```plaintext
https://bitbucket.org/netgem/connectsdkwrapper-ios.git
```

## Usage

### Importing

To use ConnectSDKWrapper in your Swift code, simply import the module:

```swift
import ConnectSDKWrapper
```

### Discovery

Discover LG WebOS devices on the network:

You can use the `ConnectSDKWrapperBuilder` to build an instance of `ConnectSDKWrapper` with customized configurations. Here's how you can do it:

```swift
import ConnectSDKWrapper

// Create a builder instance
let builder = ConnectSDKWrapperBuilder()

// Set the delegate
builder.setDelegate(self)

// Set custom platforms (optional)
let customPlatforms = [.cast, .webos, .dlna]
builder.setConnectSDKPlatforms(platforms: customPlatforms)

// Available platforms [.dial, .dlna, .netcast, .ruku, .webos, .cast, .firetv]

// Build the ConnectSDKWrapper instance
let connectSDKWrapper = builder.build()
```

Ensure that you conform to the `DiscoveryManagerWrapperDelegate` protocol to receive discovery events:

```swift
extension YourViewController: DiscoveryManagerWrapperDelegate {
    func didFind(_ devices: [DeviceWrapper]) {
        // Handle discovered devices
    }
    
    func didFail(with error: Error) {
        // Handle discovery failure
    }
}
```

### Connection

Connect to a discovered device:

```swift
deviceWrapper.connect()
```

Handle device connection and disconnection events by implementing `ConnectableDeviceWrapperDelegate`.

### Browser Control

Open and close the browser on the connected device:

```swift
deviceWrapper.openBrowser(with: "https://www.example.com") { result in
    switch result {
    case .success(let launchSession):
        // Handle success
    case .failure(let error):
        // Handle failure
    }
}

deviceWrapper.closeBrowser() { result in
    switch result {
    case .success(let res):
        // Handle success
    case .failure(let error):
        // Handle failure
    }
}
```

### Media Player

To play a video media, you first need to create an instance of `DeviceWrapper` and then call the `makeMediaBuilder()` function on that instance. Here's how you can do it:

```swift
import ConnectSDKWrapper

// Assuming you have a `deviceWrapper` instance of `DeviceWrapper`
let deviceWrapper = DeviceWrapper()

// Use the `makeMediaBuilder()` function to create a `MediaPlayerBuilder` instance
let mediaPlayerBuilder = deviceWrapper.makeMediaBuilder()

// Set the media URL
let mediaURL = URL(string: "http://www.connectsdk.com/files/8913/9657/0225/test_video.mp4")

// Set other media properties if needed
let iconURL = URL(string: "http://www.connectsdk.com/files/7313/9657/0225/test_video_icon.jpg")
let title = "Sintel Trailer"
let description = "Blender Open Movie Project"
let mimeType = "video/mp4" // audio/* for audio files

mediaPlayerBuilder
    .setMediaURL(mediaURL)
    .setIconURL(iconURL)
    .setTitle(title)
    .setDescription(description)
    .setMimeType(mimeType)
    .build { result in
        switch result {
        case .success(let mediaLaunchObject):
            // Handle success
            // The media playback has started successfully
        case .failure(let error):
            // Handle failure
            // An error occurred while trying to play the media
            NSLog("play video failure: \(error.localizedDescription)")
        }
    }
```

### Device Service Capabilities

Check if a device supports certain capabilities:

```swift
if deviceWrapper.hasCapability(.appClose) {
    // Device supports closing apps
}

if deviceWrapper.hasCapabilities([.play, .pause, .stop]) {
    // Device supports media playback controls
}
```

## Example Project

For a complete demonstration of how to use ConnectSDKWrapper in your iOS application, check out the included Example project available [here](https://github.com/simbaste/ConnectSDK-iOS-Sample).

The example project showcases various features of ConnectSDKWrapper, including device discovery, connection, browser control, and more. You can use it as a reference or starting point for integrating ConnectSDKWrapper into your own project.

## License

ConnectSDKWrapper is available under the MIT license. See the [LICENSE](LICENSE) file for more information.
