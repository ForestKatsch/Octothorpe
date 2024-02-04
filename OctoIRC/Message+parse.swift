
import Foundation

extension CharacterSet {
    static var ircParameter: CharacterSet {
        var disallowed = CharacterSet()
        disallowed.insert(charactersIn: "\0\r\n ")

        return disallowed.inverted
    }

    static var ircLastParameter: CharacterSet {
        var disallowed = CharacterSet()
        disallowed.insert(charactersIn: "\0\r\n")

        return disallowed.inverted
    }

    static var ircSourceNickname: CharacterSet {
        var disallowed = CharacterSet()
        disallowed.insert(charactersIn: "\0\r\n&#! ")

        return disallowed.inverted
    }

    static var ircSourceUser: CharacterSet {
        var disallowed = CharacterSet()
        disallowed.insert(charactersIn: "\0\r\n@ ")

        return disallowed.inverted
    }

    static var ircSourceHost: CharacterSet {
        var disallowed = CharacterSet()
        disallowed.insert(charactersIn: "\0\r\n ")

        return disallowed.inverted
    }
}

class MessageStream {
    var characters: [Character] = []
    var index = 0

    init(_ string: String) {
        characters = Array(string)
    }

    var peek: Character? {
        index < characters.endIndex ? characters[index] : nil
    }

    func read() -> Character? {
        let next = peek
        index += 1
        return next
    }

    func expect(_ expecting: String) throws {
        guard let next = peek else {
            throw OctoIRCError.parse("expected \(expecting)")
        }

        if String(next) != expecting {
            throw OctoIRCError.parse("expected \(expecting)")
        }

        _ = read()
    }

    func unread() {
        index -= 1
    }

    func skipSpaces() -> Int {
        var skipped = 0
        while peek == " " {
            skipped += 1
            _ = read()
        }

        return skipped
    }

    // Throws if at least one space was not encountered
    func skipSpace() throws {
        if skipSpaces() == 0 {
            throw OctoIRCError.parse("expected at least one space")
        }
    }

    func read(characterSet: CharacterSet) -> String {
        var result = ""

        while true {
            guard let next = peek else {
                break
            }

            let str = String(next)

            if !characterSet.contains(str.unicodeScalars.first!) {
                break
            }

            result += str

            _ = read()
        }

        return result
    }
}

class MessageParser: MessageStream {
    var string: String

    override init(_ string: String) {
        self.string = string
        super.init(string)
    }

    var message = RawMessage(.NICK)

    func parse() -> RawMessage? {
        do {
            try parseMessage()
            return message
        } catch let OctoIRCError.parse(context) {
            log.warning("unable to parse '\(self.string)': \(context)")
            return nil
        } catch let OctoIRCError.notImplementedYet(context) {
            log.error("error parsing '\(self.string)': \(context) not implemented yet")
            return nil
        } catch {
            log.error("unknown error while parsing '\(self.string)': \(error)")
            return nil
        }
    }

    func parseMessage() throws {
        _ = skipSpaces()

        if peek == ":" {
            try parseSource()
        }

        try parseCommand()
        try parseParameters()
    }

    func parseSource() throws {
        defer {
            _ = skipSpaces()
        }

        try expect(":")

        let first = read(characterSet: .ircSourceNickname)

        // Definitively a nickname.
        if peek != "!" {
            message.source = .serverName(first)
            return
        }

        // Gobble the "!"
        _ = read()
        let user = read(characterSet: .ircSourceUser)

        var host: String?

        if peek == "@" {
            _ = read()
            host = read(characterSet: .ircSourceHost)
        }

        message.source = .user(.init(nickname: Nickname(string: first), user: user, host: host))
    }

    // Corresponds to an IRC command.
    func parseCommand() throws {
        var commandString = ""

        while true {
            guard let next = peek else {
                break
            }

            if !next.isLetter && !next.isNumber {
                break
            }

            _ = read()

            commandString.append(String(next))
        }

        if commandString.isEmpty {
            throw OctoIRCError.parse("command is empty")
        }

        guard let command = RawMessage.Command(string: commandString) else {
            throw OctoIRCError.parse("unknown command or numeric \(commandString)")
        }

        message.command = command
    }

    func parseParameters() throws {
        while peek != nil {
            try skipSpace()
            try parseParameter()
        }
    }

    func parseParameter() throws {
        var parameter = ""

        if peek == ":" {
            _ = read()
            parameter = read(characterSet: .ircLastParameter)
        } else {
            parameter = read(characterSet: .ircParameter)

            if parameter == "" {
                throw OctoIRCError.parse("empty non-final parameter")
            }
        }

        message.parameters.append(parameter)
    }
}

public extension RawMessage {
    init?(string: String) {
        let parser = MessageParser(string)
        guard let message = parser.parse() else {
            return nil
        }

        self = message
    }
}
