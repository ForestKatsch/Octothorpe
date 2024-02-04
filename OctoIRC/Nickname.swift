//
//  Nickname.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/1/24.
//

import Foundation

public struct Nickname: Identifiable, Equatable, Hashable {
    public static func == (lhs: Nickname, rhs: Nickname) -> Bool {
        lhs.nickname == rhs.nickname
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(nickname)
    }

    public var id: String { nickname }

    private let nickname: String

    public var string: String { nickname }

    public init?(string: String) {
        guard let first = string.first else {
            return nil
        }

        let bannedPrefix: Set<Character> = [
            "$", // 0x24
            ":", // 0x3a
            "#", // channel type
            "&", // local channel type / protected prefix
            "~", // founder prefix
            "@", // operator prefix
            "%", // half-op prefix
            "+", // voice prefix
        ]

        if bannedPrefix.contains(first) {
            return nil
        }

        let specialCharacters: Set<Character> = [" ", ",", "*", "?", "!", "@"]

        if !Set(string).isDisjoint(with: specialCharacters) {
            return nil
        }

        nickname = string
    }
}
