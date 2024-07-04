//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 03/07/2024.
//

import Foundation

public enum ApplicationState: String {
    case installing = "We requested user to install app on TV"
    case communicate = "Application is already launched on TV, so we just send start arguments as message to it"
    case lauched = "Se launched application on TV and passed it message as start arguments"
    case needConnection = "You need to connect to TV first"
}
