//
//  User.swift
//  OctoIRC
//
//  Created by Forest Katsch on 2/2/24.
//

import Foundation

public struct User: Hashable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.nickname == rhs.nickname
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(nickname)
        hasher.combine(user)
        hasher.combine(host)
    }

    public var nickname: Nickname?
    public var user: String?
    public var host: String?

    public init(nickname: Nickname?, user: String? = nil, host: String? = nil) {
        self.nickname = nickname
        self.user = user
        self.host = host
    }

    public enum Membership {
        case none
        case founder
        case protected
        case op
        case halfOp
        case voice

        public init?(fromPrefix string: String) {
            switch string {
            case "~":
                self = .founder
            case "&":
                self = .protected
            case "@":
                self = .op
            case "%":
                self = .halfOp
            case "+":
                self = .voice
            default:
                return nil
            }
        }
    }

    public var membership: Membership? = nil

    public init?(fromNameReply string: String) {
        guard let first = string.first else {
            return nil
        }

        // No checking is done here.
        let membershipPrefix: Set<Character> = [
            "~", // founder prefix
            "&", // protected prefix
            "@", // operator prefix
            "%", // half-op prefix
            "+", // voice prefix
        ]

        var nicknameString = string

        if membershipPrefix.contains(first) {
            membership = .init(fromPrefix: String(first))
            _ = nicknameString.removeFirst()
        } else {
            membership = Membership.none
        }

        nickname = Nickname(string: nicknameString)
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
