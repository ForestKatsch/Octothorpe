//
//  TwoColumnRoot.swift
//  Octothorpe
//
//  Created by Forest Katsch on 2/3/24.
//

import OctoIRC
import SwiftUI

struct TwoColumnRoot: View {
    @State
    var client = Client.shared

    @ViewBuilder
    var detailView: some View {
        if channel != nil {
            ChannelView(channel: $channel.unwrapped())
        } else {
            ContentUnavailableView("label.select-a-channel", systemImage: "number.square.fill", description: Text("description.select-a-channel"))
        }
    }

    @State
    var preferredColumn: NavigationSplitViewColumn = .sidebar

    @State
    var channel: IRCChannel?

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredColumn) {
            SidebarView(channel: $channel)
                .navigationSplitViewColumnWidth(min: 100, ideal: 250, max: 600)
        } detail: {
            detailView
        }
        .onAppear {
            Task {
                try await client.connect()
                print("A")
                _ = try await client.open(channel: "#general")
                print("B")
                _ = try await client.open(channel: "#octothorpe")
                print("C")
            }
        }
    }
}

#Preview {
    TwoColumnRoot()
}
