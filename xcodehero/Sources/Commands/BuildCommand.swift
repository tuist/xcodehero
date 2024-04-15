import ArgumentParser
import Foundation
import Path

struct BuildCommand: AsyncParsableCommand {
    public static var configuration: CommandConfiguration = .init(
        commandName: "build",
        abstract: "Builds an Xcode worksapce or project"
    )
    
    @Argument(
        help: "The path to the workspace or project. When not passed, it defaults to any workspace or project in the current directory.",
        completion: .file(),
        transform: { try AbsolutePath.init(validating: $0, relativeTo: .currentWorkingDirectory) }
    )
    var path: AbsolutePath?
    
    init() {}
    func run() async throws {
        try await self.run(context: XcodeHeroContext())
    }
    
    func run(context: Context) async throws {
        let params = try await BuildInputParserAndValidator(context: context).parseAndValidate(path: self.path)
    }
}
