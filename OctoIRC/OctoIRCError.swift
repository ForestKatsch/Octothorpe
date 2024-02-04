//
//  OctoIRCError.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/3/24.
//

import Foundation

public enum OctoIRCError: Error {
    // Not connected to a server
    case notConnected

    // Not joined to a channel
    case notJoined

    // Message parsing error
    case parse(_ context: String)
    case notImplementedYet(_ context: String)
}
