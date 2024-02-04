//
//  IRCMessage.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/1/24.
//

import Foundation

// This is an IRC message. This is the low-level underlying format through which all IRC communications happen.
public struct RawMessage {
    public enum Source {
        case serverName(_ name: String)
        case user(_ user: User)

        var string: String {
            switch self {
            case let .serverName(name):
                ":\(name)"
            case let .user(user):
                user.string
            }
        }
    }

    public enum Command: String {
        case CAP
        case PASS
        case NICK
        case USER
        case JOIN
        case PRIVMSG
        case PING
        case PONG
        case TOPIC

        case RPL_WELCOME = "001"
        case RPL_TOPIC = "332"
        case RPL_NAMREPLY = "353"

        var string: String {
            return self.rawValue
        }

        init?(string: String) {
            self.init(rawValue: string)
        }
    }

    // var tags: [String: String] = [:]

    var source: Source?

    var command: Command

    var parameters: [String] = []

    public init(_ command: Command, _ parameters: [String] = []) {
        self.command = command
        self.parameters = parameters
    }

    public init(source: Source, _ command: Command, _ parameters: [String] = []) {
        self.source = source
        self.command = command
        self.parameters = parameters
    }

    static func CAP(_ parameters: [String]) -> RawMessage {
        .init(.CAP, parameters)
    }

    static func PASS(serverPassword password: String) -> RawMessage {
        .init(.PASS, [password])
    }

    static func NICK(_ nickname: Nickname) -> RawMessage {
        .init(.NICK, [nickname.string])
    }

    static func USER(_ identity: Identity) -> RawMessage {
        .init(.USER, [identity.username, "0", "*", identity.realName])
    }

    static func JOIN(_ channel: String) -> RawMessage {
        .init(.JOIN, [channel])
    }

    static func PRIVMSG(_ channel: String, message: String) -> RawMessage {
        .init(.PRIVMSG, [channel, message])
    }

    // The message as it should be sent, without "\r\n".
    public var message: String {
        var parts: [String] = []

        if let source {
            parts.append(source.string)
        }

        parts.append(command.string)

        parameters.enumerated().forEach { index, parameter in
            if index == parameters.endIndex - 1 {
                if parameter.contains(" ") || parameter.isEmpty || parameter.first == ":" {
                    parts.append(":" + parameter)
                    return
                }
            }
            parts.append(parameter)
        }

        return parts.joined(separator: " ")
    }
}
