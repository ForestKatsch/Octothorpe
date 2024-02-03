//
//  User.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/2/24.
//

import Foundation

public struct User {
    var nickname: Nickname?
    var user: String?
    var host: String?

    public init(nickname: Nickname?, user: String? = nil, host: String? = nil) {
        self.nickname = nickname
        self.user = user
        self.host = host
    }

    var string: String {
        var ret = ":\(nickname?.string ?? "")"

        if let user {
            ret += "!\(user)"
        }

        if let host {
            ret += "@\(host)"
        }

        return ret
    }
}
