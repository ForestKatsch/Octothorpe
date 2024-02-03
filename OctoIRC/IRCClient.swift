//
//  Server.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/1/24.
//

import Foundation
import os

let log = Logger(subsystem: "com.forestkatsch.octoirc", category: "IRCClient")

public protocol IRCTransport {
    var received: ((_: String) async -> Void)? { get set }
    func connect() async throws -> Void
    func send(_: Message) async throws -> Void
}

@Observable
// Connects as a client through a single Transport. This will normally connect to one server.
open class IRCClient {
    var transport: IRCTransport
    var options: Options

    private var temporaryReceivedListener: ((_ message: Message) -> Void)?

    public struct Options {
        public let identity: Identity
        public var serverPassword: String?

        public init(_ identity: Identity) {
            self.identity = identity
        }
    }

    public init(_ transport: IRCTransport, options: Options) {
        self.transport = transport
        self.options = options

        self.transport.received = received
    }

    func send(_ message: Message) async throws {
        try await transport.send(message)
        log.debug("> \(message.message)")
    }

    func received(_ received: String) async {
        guard let message = Message(string: received) else {
            return
        }

        log.debug("< \(message.message)")

        do {
            switch message.command {
            case .PING:
                try await handle(ping: message)
            default:
                break
            }
        } catch {
            log.error("Unknown error while handling message '\(message.message)'")
            // TODO:
        }

        if let temporaryReceivedListener {
            temporaryReceivedListener(message)
        }
    }

    func handle(ping message: Message) async throws {
        guard let token = message.parameters.first else {
            // No token!
            return
        }

        log.trace("Replying to 'ping' '\(token)'")

        try await send(Message(.PONG, [token]))
    }

    // TODO: add "disconnected" logic to IRCTransport
    // Returns the first message for which `filter` returns `true`.
    func onReceive(filter: @escaping (Message) -> Bool) async throws -> Message {
        var pendingMessage: Message?

        temporaryReceivedListener = { message in
            pendingMessage = message
        }

        let result = await withCheckedContinuation { continuation in
            if let pendingMessage {
                if filter(pendingMessage) == true {
                    continuation.resume(returning: pendingMessage)
                    temporaryReceivedListener = nil
                    return
                }
            }

            temporaryReceivedListener = { message in
                if filter(message) {
                    continuation.resume(returning: message)
                    self.temporaryReceivedListener = nil
                }
            }
        }

        log.debug("Received '\(result.command.string)' message we were waiting for")

        return result
    }

    func onReceive(anyOf commandSet: Set<Message.Command>) async throws -> Message {
        log.debug("Waiting for any of \(commandSet.map { "'\($0.string)'" }.joined(separator: ", "))")

        return try await onReceive(filter: {
            commandSet.contains($0.command)
        })
    }

    func onReceive(command: Message.Command) async throws -> Message {
        try await onReceive(anyOf: [command])
    }

    public func capabilityNegotiation() async throws {
        let response = try await onReceive(anyOf: [.CAP, .RPL_WELCOME])

        // No capability negotiation support.
        if response.command == .RPL_WELCOME {
            return
        }

        try await send(.CAP(["END"]))
    }

    public func join(channel: String) async throws {
        try await send(.JOIN(channel))

        _ = try await onReceive {
            $0.command == .JOIN && $0.parameters.first == channel
        }
    }

    public func connect() async throws {
        try await transport.connect()

        try await send(.CAP(["LS", "302"]))

        if let serverPassword = options.serverPassword {
            try await send(.PASS(serverPassword: serverPassword))
        }

        try await send(.NICK(options.identity.nickname))
        try await send(.USER(options.identity))

        try await capabilityNegotiation()

        // try await onReceive(.USER())
        try await join(channel: "#octothorpe")

        try await send(.PRIVMSG("#octothorpe", message: "Hello fuckers"))
    }
}
