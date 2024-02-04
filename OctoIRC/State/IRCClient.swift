//
//  IRCServer.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/3/24.
//

import Foundation

@Observable
open class IRCClient: RawClient {
    public var serverChannel: IRCServerChannel!
    public var channels: [String: IRCClientChannel] = [:]

    public var name: String {
        transport.name
    }

    override public init(_ transport: any IRCTransport, options: Options) {
        super.init(transport, options: options)
        serverChannel = .init(client: self)

        onMessage { message in
            switch message.command {
            case .PRIVMSG:
                self.handle(privmsg: message)
            default:
                .ignored
            }
        }
    }

    func handle(privmsg message: RawMessage) -> MessageListener.Outcome {
        if message.parameters.count != 2 {
            return .ignored
        }

        let targets = message.parameters[0].split(separator: ",")

        guard let message = IRCMessage(client: self, rawMessage: message) else {
            print("! unable to create IRC message from \(message.message)")
            return .ignored
        }

        for target in targets {
            if let channel = channels[String(target)] {
                channel.append(message: message)
            }
        }

        return .handled
    }

    public func open(channel name: String) async throws -> IRCClientChannel {
        if !isConnected {
            throw OctoIRCError.notConnected
        }

        if let existingChannel = channels[name] {
            return existingChannel
        }

        let channel = IRCClientChannel(client: self, name: name)
        channels[name] = channel
        return channel
    }
}
