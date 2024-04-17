import ArgumentParser
import Command
import Foundation
import Path
import SwiftTerminal
import XcbeautifyLib

enum BuildCommandError: FatalError {
    case buildError(String, args: [String])

    var context: String {
        switch self {
        case let .buildError(_, args):
            "We tried to build the project by running: \(args.joined(separator: " "))"
        }
    }

    var nextSteps: [String] {
        switch self {
        case .buildError:
            ["Open the project in Xcode and ensure it  builds successfully"]
        }
    }

    var description: String {
        switch self {
        case let .buildError(stderr, _):
            "The build failed with the following error:\n\(stderr)"
        }
    }
}

struct BuildCommand: AsyncParsableCommand {
    public static var configuration: CommandConfiguration = .init(
        commandName: "build",
        abstract: "Builds an Xcode workspace or project"
    )

    @Argument(
        help: "The path to the workspace or project. When not passed, it defaults to any workspace or project in the current directory.",
        completion: .file(),
        transform: { try AbsolutePath(validating: $0, relativeTo: .currentWorkingDirectory) }
    )
    var path: AbsolutePath?

    @Flag(
        help: "When passed, it cleans derived data before building."
    )
    var clean: Bool = false

    @Option(
        help: "The name of the scheme to build."
    )
    var scheme: String

    @Flag(
        help: "When passed it outputs the verbose version of the logs"
    )
    var verbose: Bool = false

    @Flag(
        help: "Forces disabling the interactive experience"
    )
    var noTty: Bool = false

    @Flag(
        help: "Forces disabling the colored experience"
    )
    var noColor: Bool = false

    init() {}

    func run() async throws {
        let context = XcodeHeroContext()
        try await run(context: context)
    }
    
    func run(context: Context) async throws {
        let input = try await input()
        let arguments = xcodebuildArguments(input: input)
        try await xcodebuild(arguments: arguments, input: input, context: context)
    }

    private func xcodebuild(arguments: [String], input: BuildInput, context: Context) async throws {
        let commandRunner = CommandRunner()

        let formatter = await XCBeautifier(
            colored: context.shouldColor,
            renderer: .terminal,
            preserveUnbeautifiedLines: false,
            additionalLines: { nil }
        )
        let environment = await Environment(
            isInteractive: context.isInteractive,
            shouldColor: context.shouldColor
        )

        do {
            let stream = commandRunner.run(arguments: arguments)

            if input.verbose {
                for try await event in stream {
                    switch event {
                    case let .standardError(data): try FileHandle.standardError.write(contentsOf: data)
                    case let .standardOutput(data): try FileHandle.standardOutput.write(contentsOf: data)
                    }
                }
            } else {
                try await CollapsibleStream.render(
                    title: arguments.joined(separator: " "),
                    stream: stream.map { event -> CollapsibleStream.Event in
                        switch event {
                        case .standardError:
                            return .error(
                                event.utf8String.split(separator: "\n")
                                    .compactMap { formatter.format(line: String($0)) }
                                    .joined(separator: "\n")
                            )
                        case .standardOutput:
                            return .output(
                                event.utf8String.split(separator: "\n")
                                    .compactMap { formatter.format(line: String($0)) }
                                    .joined(separator: "\n")
                            )
                        }
                    }.eraseToAsyncThrowingStream(),
                    theme: xcodeHeroTheme,
                    environment: environment,
                    standardPipelines: context.standardPipelines
                )
            }

            print("")
            await CompletionMessage.render(
                message: .success(action: "The build of the scheme \(scheme) from project \(input.projectPath)"),
                theme: xcodeHeroTheme,
                environment: environment,
                standardPipelines: context.standardPipelines
            )
        } catch {
            if let commandError = error as? CommandError {
                switch commandError {
                case let .terminated(_, stderr):
                    throw BuildCommandError.buildError(stderr, args: arguments)
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
    }

    private func input() async throws -> BuildInput {
        try await BuildInputParserAndValidator(
            envVariables: XcodeHeroContext.defaultEnvVariables(),
            currentWorkingDirectory: XcodeHeroContext
                .defaultCurrentWorkingDirectory()
        )
        .parseAndValidate(path: path, clean: clean, verbose: verbose, noTty: noTty, noColor: noColor)
    }

    private func xcodebuildArguments(input: BuildInput) -> [String] {
        var arguments = ["/usr/bin/xcrun", "xcodebuild", "-scheme", scheme]
        switch input.projectPath {
        case let .workspace(absolutePath):
            arguments.append(contentsOf: ["-workspace", absolutePath.pathString])
        case let .project(absolutePath):
            arguments.append(contentsOf: ["-project", absolutePath.pathString])
        }
        if input.clean {
            arguments.append("clean")
        }
        arguments.append("build")
        return arguments
    }
}
