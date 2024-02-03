//
//  Nickname.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/1/24.
//

import Foundation

public struct Nickname {
    private let nickname: String

    var string: String { nickname }

    public init?(string: String) {
        guard let first = string.first else {
            return nil
        }

        let bannedFirst: Set<Character> = [
            "$", // 0x24
            ":", // 0x3a
            "#", // channel type
            "&", // local channel type / protected prefix
            "~", // founder prefix
            "@", // operator prefix
            "%", // half-op prefix
            "+", // voice prefix
        ]

        if bannedFirst.contains(first) {
            return nil
        }

        let specialCharacters: Set<Character> = [" ", ",", "*", "?", "!", "@"]

        if !Set(string).isDisjoint(with: specialCharacters) {
            return nil
        }

        nickname = string
    }
}
