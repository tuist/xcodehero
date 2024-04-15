import Foundation
import ArgumentParser

@main
struct XcodeHeroCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
            commandName: "xcodehero",
            abstract: "xcodebuild with superpowers",
            subcommands: [BuildCommand.self]
    )
}
