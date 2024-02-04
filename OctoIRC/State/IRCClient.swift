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
