import Foundation
import Path

struct BuildInput {
    let projectPath: ProjectPath
    let clean: Bool
    let verbose: Bool
    let noTty: Bool
    let noColor: Bool
}

protocol BuildInputParserAndValidating {
    func parseAndValidate(path: AbsolutePath?, clean: Bool, verbose: Bool, noTty: Bool, noColor: Bool) async throws -> BuildInput
}

enum BuildInputParserError: FatalError {
    case projectNotFound(AbsolutePath)
    case nonSupportedProject(AbsolutePath)
    case projectNotFoundInWorkingDirectory(AbsolutePath)

    var context: String {
        switch self {
        case .projectNotFound, .nonSupportedProject, .projectNotFoundInWorkingDirectory:
            return "We were trying to locate and validate the project at the given path before building it"
        }
    }

    var description: String {
        switch self {
        case let .projectNotFound(path):
            return "We couldn't find the project at path \(path.pathString)"
        case let .nonSupportedProject(path):
            return "The project at path \(path.pathString) is not supported"
        case let .projectNotFoundInWorkingDirectory(path):
            return "We couldn't find neither an Xcode workspace or project at path \(path.pathString)"
        }
    }

    var nextSteps: [String] {
        switch self {
        case let .projectNotFound(path):
            return [
                "Ensure the path \(path.pathString) is a valid path and points to an existing project",
            ]
        case let .nonSupportedProject(path):
            return [
                "Ensure the path \(path.pathString) is either a .xcworkspace or a .xcodeproj",
            ]
        case let .projectNotFoundInWorkingDirectory(workingDirectory):
            return [
                "Ensure an Xcode workspace or project is available in the directory \(workingDirectory.pathString) or pass the path to the workpace or project",
            ]
        }
    }
}

struct BuildInputParserAndValidator: BuildInputParserAndValidating {
    private let envVariables: [String: String]
    private let currentWorkingDirectory: AbsolutePath

    init(envVariables: [String: String], currentWorkingDirectory: AbsolutePath) {
        self.envVariables = envVariables
        self.currentWorkingDirectory = currentWorkingDirectory
    }

    func parseAndValidate(
        path: AbsolutePath?,
        clean: Bool,
        verbose: Bool,
        noTty: Bool,
        noColor: Bool
    ) async throws -> BuildInput {
        let projectPath = try await self.path(path: path)
        return await BuildInput(
            projectPath: projectPath,
            clean: shouldClean(flag: clean),
            verbose: shouldVerbose(flag: verbose),
            noTty: shouldNoTtty(flag: noTty),
            noColor: shouldNoColor(flag: noColor)
        )
    }

    func shouldClean(flag: Bool) async -> Bool {
        if ProcessInfo.processInfo.arguments.contains(where: { $0 == "--clean" }) {
            return flag
        } else {
            if envVariables["XCODEHERO_CLEAN"] != nil { return true }
            return false
        }
    }

    func shouldVerbose(flag: Bool) async -> Bool {
        if ProcessInfo.processInfo.arguments.contains(where: { $0 == "--verbose" }) {
            return flag
        } else {
            if envVariables["XCODEHERO_VERBOSE"] != nil { return true }
            return false
        }
    }

    func shouldNoTtty(flag: Bool) async -> Bool {
        if ProcessInfo.processInfo.arguments.contains(where: { $0 == "--no-tty" }) {
            return flag
        } else {
            if envVariables["XCODEHERO_NO_TTY"] != nil { return true }
            return false
        }
    }

    func shouldNoColor(flag: Bool) async -> Bool {
        if ProcessInfo.processInfo.arguments.contains(where: { $0 == "--no-color" }) {
            return flag
        } else {
            if envVariables["XCODEHERO_NO_COLOR"] != nil { return true }
            return false
        }
    }

    func path(path: AbsolutePath?) async throws -> ProjectPath {
        if let path {
            guard FileManager.default.fileExists(atPath: path.pathString) else {
                throw BuildInputParserError.projectNotFound(path)
            }
            if path.extension == "xcodeproj" {
                return .project(path)
            } else if path.extension == "xcworkspace" {
                return .workspace(path)
            } else {
                throw BuildInputParserError.nonSupportedProject(path)
            }
        } else {
            if let workspacePath = currentWorkingDirectory.glob(pattern: "*.xcworkspace").first {
                return .workspace(workspacePath)
            } else if let projectPath = currentWorkingDirectory.glob(pattern: "*.xcodeproj").first {
                return .project(projectPath)
            } else {
                throw BuildInputParserError.projectNotFoundInWorkingDirectory(currentWorkingDirectory)
            }
        }
    }
}
