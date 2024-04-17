import ArgumentParser
import Foundation
import SwiftTerminal

public struct XcodeHeroCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "xcodehero",
        abstract: "xcodebuild with superpowers",
        subcommands: [BuildCommand.self]
    )

    public init() {}

    public static func main() async {
        let context = XcodeHeroContext()

        do {
            var command = try parseAsRoot()
            if var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.run()
            } else {
                try command.run()
            }
        } catch {
            if let _ = error as? CleanExit {
                exit(withError: error)
            } else if error.localizedDescription.contains("ArgumentParser") {
                exit(withError: error)
            } else if let fatalError = error as? FatalError {
                await CompletionMessage.render(
                    message: .error(
                        message: fatalError.description,
                        context: fatalError.context,
                        nextSteps: fatalError.nextSteps
                    ),
                    theme: xcodeHeroTheme,
                    environment: .init(isInteractive: context.isInteractive, shouldColor: context.shouldColor)
                )
            } else {
                await CompletionMessage.render(
                    message: .error(message: error.localizedDescription, context: nil, nextSteps: []),
                    theme: xcodeHeroTheme,
                    environment: .init(isInteractive: context.isInteractive, shouldColor: context.shouldColor)
                )
            }
            _exit(exitCode(for: error).rawValue)
        }
    }
}
