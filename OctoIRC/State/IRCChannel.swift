//
//  IRCChannel.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/3/24.
//

import Foundation

@Observable
public class IRCChannel: Identifiable, Hashable {
    public static func == (lhs: IRCChannel, rhs: IRCChannel) -> Bool {
        lhs.client == rhs.client && lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(client)
        hasher.combine(name)
    }

    public var isJoined: Bool { false }
    public var isJoining: Bool { false }
    public var canSend: Bool { false }

    public var hasUnread: Bool { false }

    // User-facing name
    public var name: String { "" }

    public var messages: [IRCMessage] = []

    var client: IRCClient

    init(client: IRCClient) {
        self.client = client
    }

    public func send(message _: String) async throws {}

    public func append(message: IRCMessage) {
        DispatchQueue.main.async {
            self.messages.append(message)
        }
    }
}

@Observable
public class IRCClientChannel: IRCChannel {
    public enum JoinStatus {
        case parted
        case joining
        case joined
    }

    public var joinStatus: JoinStatus = .parted

    var channelName: String
    var channelTopic: String?

    public var users: Set<User> = []

    override public var isJoined: Bool { joinStatus == .joined }
    override public var isJoining: Bool { joinStatus == .joining }
    override public var canSend: Bool { isJoined }

    override public var name: String { channelName }
    public var topic: String? { channelTopic }

    public enum ChannelStatus {
        case `public`
        case secret
        case `private`
    }

    public var channelStatus: ChannelStatus? = nil

    public func join() async throws {
        if joinStatus != .parted {
            // No-op
            return
        }

        joinStatus = .joining
        try await client.send(.JOIN(name))

        _ = try await client.onReceive {
            $0.command == .JOIN && $0.parameters.first == self.name
        }
        joinStatus = .joined
    }

    func insert(user: User) {
        users.insert(user)
    }

    init(client: IRCClient, name: String) {
        self.channelName = name
        super.init(client: client)

        client.onMessage(id: name) { message in
            switch message.command {
            case .RPL_TOPIC:
                // <client> <channel> <topic>
                if message.parameters.count != 3 || message.parameters[1] != name {
                    return .ignored
                }

                self.channelTopic = message.parameters[2]
                return .handled
            case .TOPIC:
                // <channel> [<topic>]
                if message.parameters.count < 1 || message.parameters[0] != name {
                    return .ignored
                }

                self.channelTopic = message.parameters.count >= 2 ? message.parameters[1] : nil
                return .handled
            case .RPL_NAMREPLY:
                // <client> <channelStatus> <channel> <nicknames>
                // (where "nicknames" is space-separated)
                if message.parameters.count < 4 || message.parameters[2] != name {
                    return .ignored
                }

                let userList = message.parameters[3].components(separatedBy: .whitespaces)

                userList.forEach { user in
                    if let user = User(fromNameReply: user) {
                        self.insert(user: user)
                    }
                }

                return .handled
            default:
                return .ignored
            }
        }
    }

    override public func send(message: String) async throws {
        if !isJoined {
            throw OctoIRCError.notJoined
        }

        let msg = RawMessage.PRIVMSG(name, message: message)

        append(message: .init(source: client.source, message: message))

        try await client.send(msg)
    }
}

@Observable
public class IRCServerChannel: IRCChannel {
    public static func == (lhs: IRCServerChannel, rhs: IRCServerChannel) -> Bool {
        lhs.client == rhs.client
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine(client)
    }

    override public var name: String { client.transport.name }

    override public var isJoined: Bool {
        client.connectionStatus != .disconnected
    }

    override public var isJoining: Bool { client.isConnecting }
    override public var canSend: Bool { client.connectionStatus == .connected }
}
