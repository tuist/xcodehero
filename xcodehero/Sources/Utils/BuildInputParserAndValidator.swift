import Foundation
import Path

struct BuildInputParams {
    let projectPath: ProjectPath
}

protocol BuildInputParserAndValidating {
    func parseAndValidate(path: AbsolutePath?) async throws -> BuildInputParams
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
                "Ensure the path \(path.pathString) is a valid path and points to an existing project"
            ]
        case let .nonSupportedProject(path):
            return [
                "Ensure the path \(path.pathString) is either a .xcworkspace or a .xcodeproj"
            ]
        case let .projectNotFoundInWorkingDirectory(workingDirectory):
            return [
                "Ensure an Xcode workspace or project is available in the directory \(workingDirectory.pathString) or pass the path to the workpace or project"
            ]
        }
    }
}

struct BuildInputParserAndValidator: BuildInputParserAndValidating {
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    func parseAndValidate(path: AbsolutePath?) async throws -> BuildInputParams {
        let projectPath = try await self.path(path: path)
        let configFiles = try self.loadConfigFiles(path: projectPath.directory)
        
        return BuildInputParams(projectPath: projectPath)
    }
    
    func path(path: AbsolutePath?) async throws -> ProjectPath {
        if let path = path {
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
            if let workspacePath = await context.currentWorkingDirectory.glob(pattern: "*.xcworkspace").first {
                return .workspace(workspacePath)
            } else if let projectPath = await context.currentWorkingDirectory.glob(pattern: "*.xcodeproj").first {
                return .project(projectPath)
            } else {
                throw BuildInputParserError.projectNotFoundInWorkingDirectory(await context.currentWorkingDirectory)
            }
        }
    }
    
    private func loadConfigFiles(path: AbsolutePath) throws -> ConfigFiles {
        return ConfigFiles(local: [:], user: [:], system: [:])
    }
    
//    private func 
}
