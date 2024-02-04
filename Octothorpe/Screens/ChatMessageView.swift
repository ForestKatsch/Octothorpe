//
//  ChatMessageView.swift
//  Octothorpe
//
//  Created by Forest Katsch on 2/3/24.
//

import OctoIRC
import SwiftUI

private struct ChatMessage: View {
    var message: IRCMessage

    init(_ message: IRCMessage) {
        self.message = message
    }

    func sourceUser(_ user: User) -> some View {
        Text(user.nickname?.string ?? "")
            .bold()
        // TODO: only if fixed width
        // .frame(width: 120)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            switch message.source {
            case let .user(user):
                sourceUser(user)
            default:
                EmptyView()
            }
            Text(message.message)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .monospaced()
        .if(message.sent) {
            $0.background(.foreground.opacity(0.08))
        }
        .if(message.isPing) {
            $0.background(.foreground.opacity(0.05))
        }
    }
}

struct ChatMessageView: View {
    var channel: IRCChannel

    init(_ channel: IRCChannel) {
        self.channel = channel
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 1) {
            ForEach(Array(zip(channel.messages.indices, channel.messages)), id: \.1.date) { _, message in
                ChatMessage(message)
                    .id(message.date)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
