//
//  Binding+init.swift
//  Octothorpe
//
//  Created by Forest Katsch on 2/3/24.
//

import Foundation
import SwiftUI

extension Binding {
    // Note: this is unsafe and will straight up crash if the value is actually nil.
    func unwrapped<T>() -> Binding<T> where Value == T? {
        Binding<T>(get: { self.wrappedValue! }, set: { self.wrappedValue = $0 })
    }
}
