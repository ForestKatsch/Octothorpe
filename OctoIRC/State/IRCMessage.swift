//
//  IRCMessage.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/3/24.
//

import Foundation

public struct IRCMessage {
    public var source: RawMessage.Source?
    public var message: String
    public var date: Date

    public var sent = false
    public var isPing = false

    public init?(client: IRCClient, rawMessage raw: RawMessage) {
        date = Date.now

        switch raw.command {
        case .PRIVMSG:
            if raw.parameters.count != 2 {
                return nil
            }
            source = raw.source
            message = raw.parameters[1]
        default:
            return nil
        }

        if message.contains(client.options.identity.nickname.string) {
            isPing = true
        }
    }

    public init(source: RawMessage.Source, message: String) {
        date = Date.now

        sent = true
        self.source = source
        self.message = message
    }
}
