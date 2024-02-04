//
//  NetworkTransport.swift
//  Octothorpe
//
//  Created by Forest Katsch on 2/1/24.
//

import Foundation
import Network
import OctoIRC

class NetworkTransport: IRCTransport {
    static func == (_: NetworkTransport, _: NetworkTransport) -> Bool {
        true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(host)
        hasher.combine(port)
    }

    var received: ((String) async -> Void)?

    var pendingMessage: String = ""

    @MainActor
    func append(_ str: String) async {
        pendingMessage.append(contentsOf: str)

        if pendingMessage.hasSuffix("\r\n") {
            defer {
                pendingMessage = ""
            }

            guard let received else {
                print("message will be lost!!!")
                return
            }

            await received(pendingMessage.replacingOccurrences(of: "\r\n", with: ""))
        }
    }

    let connection: NWConnection
    let queue: DispatchQueue = .global(qos: .userInitiated)

    var canSend: Bool {
        connection.state == .ready
    }

    var host: String
    var port: UInt16

    var name: String { host }

    init?(_ host: String, port: UInt16) {
        self.host = host
        self.port = port

        let host = NWEndpoint.Host(host)
        guard let port = NWEndpoint.Port(rawValue: port) else { return nil }

        connection = NWConnection(host: host, port: port, using: .tcp)
        listenByte()
    }

    func onStateUpdate(_: NWConnection.State) {}

    func connect() async throws {
        print("Connecting to \(connection.endpoint.debugDescription)")
        return await withCheckedContinuation { continuation in
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    continuation.resume()
                case .preparing:
                    fallthrough
                case .setup:
                    break
                case .cancelled:
                    // TODO: disconnect
                    print("cancelled")
                case let .failed(err):
                    // TODO: disconnect
                    print("failed: \(err)")
                case let .waiting(err):
                    // TODO: disconnect
                    print("waiting: \(err)")
                default:
                    // TODO: disconnect
                    print("omg unknown case")
                }
            }

            connection.start(queue: queue)
        }
    }

    func send(_ message: OctoIRC.Message) async throws {
        let string = message.message + "\r\n"

        return await withCheckedContinuation { continuation in
            connection.send(content: string.data(using: .utf8), completion: .contentProcessed { _ in
                continuation.resume()
            })
        }
    }

    func listenByte() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1, completion: { data, _, isComplete, error in
            if let error {
                print("Receive error: \(error)")
                return
            }

            guard let data else { return }

            guard let str = String(data: data, encoding: .utf8) else {
                return
            }

            Task {
                await self.append(str)
                if !isComplete {
                    self.listenByte()
                }
            }
        })
    }
}
