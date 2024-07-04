//
//  File.swift
//  
//
//  Created by Stephane SIMO MBA on 04/07/2024.
//

import Foundation

enum ApplicationInfo {
    case needParing
    case failedParing(error: Error)
    case retrievedInfo(info: [String: AnyObject]?)
    case retrievedInfoFailed(error: Error)
}
