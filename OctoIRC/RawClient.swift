//
//  Server.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/1/24.
//

import Foundation
import os

let log = Logger(subsystem: "com.forestkatsch.octoirc", category: "IRCClient")

public protocol IRCTransport: Hashable {
    var name: String { get }
    var received: ((_: String) async -> Void)? { get set }
    func connect() async throws -> Void
    func send(_: Message) async throws -> Void
}

struct MessageListener: Equatable {
    static func == (lhs: MessageListener, rhs: MessageListener) -> Bool {
        lhs.id == rhs.id
    }

    enum Outcome {
        case ignored
        case handled
        case destroy
    }

    typealias Callback = (_ message: Message) async -> Outcome?

    var id: AnyHashable
    var callback: Callback

    init(id: AnyHashable = UUID(), _ callback: @escaping Callback) {
        self.id = id
        self.callback = callback
    }
}

@Observable
// Connects as a client through a single Transport. This will normally connect to one server.
open class RawClient: Equatable, Hashable {
    public static func == (_: RawClient, _: RawClient) -> Bool {
        true
    }

    public func hash(into _: inout Hasher) {
        // hasher.combine(client)
    }

    public enum ConnectionStatus {
        case disconnected
        case connecting
        case handshaking
        case connected
    }

    public var connectionStatus: ConnectionStatus = .disconnected

    public var isConnected: Bool {
        connectionStatus == .connected
    }

    public var isConnecting: Bool {
        connectionStatus == .connecting || connectionStatus == .handshaking
    }

    var transport: any IRCTransport
    var options: Options

    private var listeners: [MessageListener] = []

    public struct Options {
        public let identity: Identity
        public var serverPassword: String?

        public init(_ identity: Identity) {
            self.identity = identity
        }
    }

    public init(_ transport: any IRCTransport, options: Options) {
        self.transport = transport
        self.options = options

        self.transport.received = received

        setupListeners()
    }

    func setupListeners() {
        onMessage(call: self.handle)
    }

    func send(_ message: Message) async throws {
        log.debug("> \(message.message)")
        try await transport.send(message)
    }

    func received(_ received: String) async {
        guard let message = Message(string: received) else {
            return
        }

        log.debug("< \(message.message)")

        for listener in listeners {
            if let outcome = await listener.callback(message) {
                switch outcome {
                case .destroy:
                    if let index = listeners.firstIndex(where: { $0 == listener }) {
                        listeners.remove(at: index)
                    }
                case .handled:
                    break
                case .ignored:
                    continue
                }
            }
        }
    }

    func handle(ping message: Message) async -> MessageListener.Outcome? {
        if message.command != .PING {
            return nil
        }

        guard let token = message.parameters.first else {
            // No token!
            return nil
        }

        log.trace("Replying to 'ping' '\(token)'")

        try? await send(Message(.PONG, [token]))

        return .handled
    }

    func onMessage(id: AnyHashable = UUID(), call callback: @escaping MessageListener.Callback) {
        listeners.append(.init(id: id, callback))
    }

    func delete(listeners id: AnyHashable) {
        listeners.removeAll { $0.id == id }
    }

    // TODO: add "disconnected" logic to IRCTransport
    // Returns the first message for which `filter` returns `true`.
    func onReceive(filter: @escaping (Message) -> Bool) async throws -> Message {
        let result = await withCheckedContinuation { continuation in
            onMessage { message in
                if filter(message) {
                    continuation.resume(returning: message)
                    return .destroy
                }

                return nil
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
            print("welcome!")
            return
        }

        try await send(.CAP(["END"]))

        // Wait for the welcome message.
        _ = try await onReceive(anyOf: [.RPL_WELCOME])
    }

    public func connect() async throws {
        connectionStatus = .connecting

        try await transport.connect()

        connectionStatus = .handshaking

        try await send(.CAP(["LS", "302"]))

        if let serverPassword = options.serverPassword {
            try await send(.PASS(serverPassword: serverPassword))
        }

        try await send(.NICK(options.identity.nickname))
        try await send(.USER(options.identity))

        try await capabilityNegotiation()

        connectionStatus = .connected

        log.info("Successfully completed handshake and connected to \(self.transport.name)")
    }
}
