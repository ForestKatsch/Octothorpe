//
//  UserListView.swift
//  Octothorpe
//
//  Created by Forest Katsch on 2/3/24.
//

import OctoIRC
import SwiftUI

private extension IRCClientChannel {
    var usersSorted: [User] {
        users.sorted { a, b in
            a.nickname?.string ?? "" < b.nickname?.string ?? ""
        }
    }
}

private extension User {
    var labelView: some View {
        Text(nickname?.string ?? "fuck")
            .monospaced()
    }
}

private extension User.Membership {
    var label: LocalizedStringKey {
        switch self {
        case .founder:
            "label.user-membership.founder"
        case .protected:
            "label.user-membership.protected"
        case .op:
            "label.user-membership.op"
        case .halfOp:
            "label.user-membership.half-op"
        case .voice:
            "label.user-membership.voice"
        case .none:
            "label.user-membership.none"
        }
    }

    var prefix: LocalizedStringKey? {
        switch self {
        case .founder:
            "prefix.user-membership.founder"
        case .protected:
            "prefix.user-membership.protected"
        case .op:
            "prefix.user-membership.op"
        case .halfOp:
            "prefix.user-membership.half-op"
        case .voice:
            "prefix.user-membership.voice"
        case .none:
            nil
        }
    }
}

private struct UserSection: View {
    var membership: User.Membership
    var users: [User]

    init(_ membership: User.Membership, users: [User]) {
        self.membership = membership
        self.users = users
    }

    var list: [User] {
        users.filter { $0.membership == membership }
    }

    var body: some View {
        if list.isEmpty {
            EmptyView()
        } else {
            Section {
                ForEach(list, id: \.self) { user in
                    user.labelView
                }
            } header: {
                HStack {
                    Text(membership.label)
                    Spacer()
                    if let prefix = membership.prefix {
                        Text(prefix)
                            .bold()
                    }
                    Text(list.count.formatted())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct UserListView: View {
    @Environment(\.dismiss)
    var dismiss

    var channel: IRCClientChannel

    init(_ channel: IRCClientChannel) {
        self.channel = channel
    }

    var body: some View {
        List {
            UserSection(.founder, users: channel.usersSorted)
            UserSection(.protected, users: channel.usersSorted)
            UserSection(.op, users: channel.usersSorted)
            UserSection(.halfOp, users: channel.usersSorted)
            UserSection(.voice, users: channel.usersSorted)
            UserSection(.none, users: channel.usersSorted)
        }
        #if !os(macOS)
        .listStyle(.insetGrouped)
        #endif
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: { dismiss() }) {
                    Label("action.dismiss-sheet", systemImage: "xmark")
                }
            }
        }
    }
}
