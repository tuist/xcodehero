import Foundation
import ArgumentParser
import SwiftTerminal

struct XcodeHeroCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "xcodehero",
        abstract: "xcodebuild with superpowers",
        subcommands: [BuildCommand.self]
    )
    
    public static func main() async {
        do {
            var command = try parseAsRoot()
            if var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.run()
            } else {
                try command.run()
            }
        } catch {
            if let cleanExit = error as? CleanExit {
                exit(withError: error)
            } else if error.localizedDescription.contains("ArgumentParser") {
                exit(withError: error)
            }
            else if let fatalError = error as? FatalError {
                await CompletionMessage.render(message: .error(message: fatalError.description, context: fatalError.context, nextSteps: fatalError.nextSteps), theme: xcodeHeroTheme)
            } else {
                await CompletionMessage.render(message: .error(message: error.localizedDescription, context: nil, nextSteps: []), theme: xcodeHeroTheme)
            }
            _exit(exitCode(for: error).rawValue)
        }
    }
}
