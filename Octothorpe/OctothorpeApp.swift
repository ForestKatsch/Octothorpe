//
//  OctothorpeApp.swift
//  Octothorpe
//
//  Created by Forest Katsch on 2/1/24.
//

import SwiftUI

@main
struct OctothorpeApp: App {
    var body: some Scene {
        WindowGroup {
            TwoColumnRoot()
        }.commands {
            SidebarCommands() // 1
        }
        #if os(visionOS)
        .defaultSize(width: 650, height: 700)
        #elseif os(macOS)
        .defaultSize(width: 850, height: 600)
        #endif
    }
}
