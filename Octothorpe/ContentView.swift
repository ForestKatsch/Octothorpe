//
//  ContentView.swift
//  Octothorpe
//
//  Created by Forest Katsch on 2/1/24.
//

import SwiftUI

struct ContentView: View {
    @State
    var client = Client.shared

    var body: some View {
        VStack {
            Image(systemName: "server.rack")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button(action: {}) { Text("Say 'Hello, fuckers'") }
        }
        .onAppear {
            Task {
                try await client.connect()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
