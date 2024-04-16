import ArgumentParser
import Foundation
import Path
import Command
import XcbeautifyLib
import SwiftTerminal

enum MyError: FatalError {
    var context: String { "We were trying something" }
    
    var nextSteps: [String] { ["foo", "bar"] }
    
    var description: String { "Error" }
    
    case test
    
}

struct BuildCommand: AsyncParsableCommand {
    public static var configuration: CommandConfiguration = .init(
        commandName: "build",
        abstract: "Builds an Xcode workspace or project"
    )
    
    @Argument(
        help: "The path to the workspace or project. When not passed, it defaults to any workspace or project in the current directory.",
        completion: .file(),
        transform: { try AbsolutePath.init(validating: $0, relativeTo: .currentWorkingDirectory) }
    )
    var path: AbsolutePath?
    
    @Flag(
        help: "When passed, it cleans derived data before building."
    )
    var clean = false
    
    @Option(
        help: "The name of the scheme to build."
    )
    var scheme: String
    
    init() {}
    func run() async throws {
        try await self.run(context: XcodeHeroContext())
    }
    
    func run(context: Context) async throws {
        let params = try await BuildInputParserAndValidator(context: context).parseAndValidate(path: self.path)
        let commandRunner = CommandRunner()
        var arguments = ["/usr/bin/xcrun", "xcodebuild", "-scheme", scheme]
        switch params.projectPath {
        case .workspace(let absolutePath):
            arguments.append(contentsOf: ["-workspace", absolutePath.pathString])
        case .project(let absolutePath):
            arguments.append(contentsOf: ["-project", absolutePath.pathString])
        }
        if clean {
            arguments.append("clean")
        }
        arguments.append("build")

        let formatter = await XCBeautifier(
            colored: context.shouldColor,
            renderer: .terminal,
            preserveUnbeautifiedLines: false,
            additionalLines: { nil }
        )

        let stream = commandRunner.run(arguments: arguments).map({ event -> CollapsibleStream.Event in
            switch event {
            case .standardError(_):
                return .error(event.utf8String.split(separator: "\n")
                    .compactMap({ formatter.format(line: String($0 ))})
                    .joined(separator: "\n"))
            case .standardOutput(_):
                return .output(event.utf8String.split(separator: "\n")
                    .compactMap({ formatter.format(line: String($0 ))})
                    .joined(separator: "\n"))
            }
        }).eraseToAsyncThrowingStream()
        
        try await CollapsibleStream.render(title: arguments.joined(separator: " "), stream: stream, theme: xcodeHeroTheme)
    }
}
