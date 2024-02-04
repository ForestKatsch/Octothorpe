//
//  Sidebar.swift
//  Octothorpe
//
//  Created by Forest Katsch on 2/3/24.
//

import OctoIRC
import SwiftUI

extension IRCChannel {
    @ViewBuilder
    var joinPartButton: some View {
        if let channel = self as? IRCClientChannel {
            switch channel.joinStatus {
            case .joining:
                Text("message.joining-channel")
            case .joined:
                Button(action: { Task {
                    // try? await join()
                }}) { Text("action.part-channel") }
            case .parted:
                Button(action: { Task {
                    try? await channel.join()
                }}) { Text("action.join-channel") }
            }
        }
    }

    @ViewBuilder
    var contextMenu: some View {
        joinPartButton
    }

    @ViewBuilder
    var labelView: some View {
        if self is IRCServerChannel {
            Label(name, systemImage: "server.rack")
        } else {
            Label(name, systemImage: "")
        }
    }
}

public extension IRCClient {
    var channelList: [IRCClientChannel] {
        Array(channels.values).sorted { a, b in a.name < b.name }
    }
}

private struct ChannelItem: View {
    var channel: IRCChannel

    init(_ channel: IRCChannel) {
        self.channel = channel
    }

    var body: some View {
        HStack {
            channel.labelView
                .contextMenu {
                    channel.contextMenu
                }
            Spacer()
            if channel.isJoining {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .bold(channel.hasUnread)
        .if(!channel.isJoined) {
            $0.foregroundStyle(.secondary)
        }
        .tag(channel)
    }
}

private struct ServerView: View {
    var client: Client

    @State
    var expanded = true

    var body: some View {
        ChannelItem(client.serverChannel)
        ForEach(client.channelList, id: \.self) { chan in
            ChannelItem(chan)
        }
    }
}

struct SidebarView: View {
    @State
    var client = Client.shared

    @Binding
    var channel: IRCChannel?

    var body: some View {
        List(selection: $channel) {
            ServerView(client: client)
        }
        .navigationTitle("label.app-name")
        .onAppear {
            // TODO: shouldn't just select the first one.
            channel = client.serverChannel
        }
    }
}
