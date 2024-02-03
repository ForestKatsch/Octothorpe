//
//  Identity.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/1/24.
//

import Foundation

public struct Identity {
    var nickname: Nickname
    var username: String
    var realName: String

    public init(nickname: Nickname, username: String? = nil, realName: String) {
        self.nickname = nickname
        self.username = username ?? nickname.string
        self.realName = realName
    }

    public init?(nickname: String, realName: String) {
        guard let nickname = Nickname(string: nickname) else {
            return nil
        }

        self.nickname = nickname
        self.username = nickname.string
        self.realName = realName
    }
}
