//
//  ChannelView.swift
//  Octothorpe
//
//  Created by Forest Katsch on 2/3/24.
//

import OctoIRC
import SwiftUI

private struct MessageView: View {
    @Binding
    var channel: IRCChannel

    @State
    var message: String = ""

    var canSend: Bool { channel.canSend }

    /*
     @FocusState
     private var messageInputFocused: Bool
      */

    var sendButton: some View {
        Button(action: send) {
            Label("action.send-message", systemImage: "arrow.up")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .padding(4)
        .background(Circle().fill(.accent))
        .foregroundStyle(.white)
        .disabled(message.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    var messageInput: some View {
        TextField("label.message \(channel.name)", text: $message)
            // .focused($messageInputFocused)
            .frame(maxWidth: .infinity)
            .textFieldStyle(.roundedBorder)
            .padding(5)
    }

    var body: some View {
        HStack {
            messageInput
            #if !os(macOS)
                sendButton
            #endif
        }
        .onSubmit(send)
        /*
         .onChange(of: channel, initial: true) {
             print("appeared")
             messageInputFocused = true
         }
         .onKeyPress { press in
             if messageInputFocused {
                 return .ignored
             }
             print(press)
             message += press.characters
             messageInputFocused = true

             return .handled
         }
          */
    }

    func send() {
        if !canSend {
            return
        }

        let msg = message
        message = ""
        Task {
            try? await channel.send(message: msg)
        }
    }
}

struct ChannelView: View {
    @Binding
    var channel: IRCChannel

    @State
    var scrollId: Int?

    @State
    var showInspector = false

    var topic: String? {
        guard let topic = (channel as? IRCClientChannel)?.topic else { return nil }
        return topic
    }

    // Other channel types have no users.
    var showUserList: Bool {
        channel is IRCClientChannel
    }

    @ViewBuilder
    var userListView: some View {
        if let clientChannel = channel as? IRCClientChannel {
            UserListView(clientChannel)
                .inspectorColumnWidth(min: 120, ideal: 175, max: 350)
        } else {
            EmptyView()
        }
    }

    var body: some View {
        VStack {
            ScrollView {}
                .scrollPosition(id: $scrollId, anchor: .bottom)
            MessageView(channel: $channel)
        }
        #if os(macOS)
        .inspector(isPresented: $showInspector) {
            userListView
        }
        #else
        .sheet(isPresented: $showInspector) {
                    NavigationStack {
                        userListView
                            .navigationTitle("label.channel-users \(channel.name)")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
        #endif
                .navigationTitle(channel.name)
        #if os(macOS)
            .if(topic != nil) {
                $0.navigationSubtitle(topic!)
            }
        #else
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar {
                if showUserList {
                    ToolbarItem {
                        Button(action: {
                            showInspector.toggle()
                        }) {
                            Label("action.toggle-users", systemImage: "person.2.fill")
                                .labelStyle(.iconOnly)
                        }
                        .disabled(!channel.isJoined)
                    }
                }
            }
    }
}
