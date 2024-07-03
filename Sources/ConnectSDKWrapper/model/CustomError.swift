//
//  CustomError.swift
//  
//
//  Created by Stephane SIMO MBA on 29/04/2024.
//

import Foundation

/**
 A custom error type representing errors in the ConnectSDKWrapper library.
 */
public struct CustomError: Error {
    /// The error message.
    let message: String
    let code: Int
}

