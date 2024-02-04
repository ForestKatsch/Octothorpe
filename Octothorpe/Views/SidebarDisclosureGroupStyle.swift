//
//  SidebarDisclosureGroupStyle.swift
//  Octothorpe
//
//  Created by Forest Katsch on 2/3/24.
//

import SwiftUI

// TODO: remove if unnecessary
struct SidebarDisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Button(action: {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            }) {
                Label(configuration.isExpanded ? "action.collapse" : "action.expand", systemImage: "chevron.forward")
                    .labelStyle(.iconOnly)
            }
            .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
        }
        .contentShape(Rectangle())
        if configuration.isExpanded {
            configuration.content
                .disclosureGroupStyle(self)
        }
    }
}
