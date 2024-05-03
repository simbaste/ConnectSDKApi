//
//  LauncherCapability.swift
//  
//
//  Created by Stephane SIMO MBA on 29/04/2024.
//

import Foundation
import ConnectSDK

/**
 An enumeration representing launcher capabilities.
 */
public enum LauncherCapability: String {
    case any = "Launcher.Any"
    
    case app = "Launcher.App"
    case appParams = "Launcher.App.Params"
    case appClose = "Launcher.App.Close"
    case appList = "Launcher.App.List"
    case appStore = "Launcher.AppStore"
    case appStoreParams = "Launcher.AppStore.Params"
    case browser = "Launcher.Browser"
    case browserParams = "Launcher.Browser.Params"
    case hulu = "Launcher.Hulu"
    case huluParams = "Launcher.Hulu.Params"
    case netflix = "Launcher.Netflix"
    case netflixParams = "Launcher.Netflix.Params"
    case youTube = "Launcher.YouTube"
    case youTubeParams = "Launcher.YouTube.Params"
    case appState = "Launcher.AppState"
    case appStateSubscribe = "Launcher.AppState.Subscribe"
    case runningApp = "Launcher.RunningApp"
    case runningAppSubscribe = "Launcher.RunningApp.Subscribe"
}
