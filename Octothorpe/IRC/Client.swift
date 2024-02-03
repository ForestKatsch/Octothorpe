
import Foundation
import OctoIRC
import SwiftUI

@Observable
class Client: IRCClient {
    static var shared: Client {
        var options = IRCClient.Options(.init(nickname: "ROBOT", realName: "Ro Bot")!)
        options.serverPassword = "alleightofus"

        return Client(options)
    }

    init(_ options: IRCClient.Options) {
        // super.init(NetworkTransport("ceres.home", port: 6667)!, options: options)
        super.init(NetworkTransport("zlsadesign.com", port: 6667)!, options: options)
    }
}
