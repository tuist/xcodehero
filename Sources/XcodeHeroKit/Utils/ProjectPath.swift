import Foundation
import Path

enum ProjectPath: CustomStringConvertible {
    case workspace(AbsolutePath)
    case project(AbsolutePath)

    var directory: AbsolutePath {
        switch self {
        case let .project(path):
            return path.parentDirectory
        case let .workspace(path):
            return path.parentDirectory
        }
    }

    var description: String {
        switch self {
        case let .project(path):
            return "project \(path.pathString)"
        case let .workspace(path):
            return "workspace \(path.pathString)"
        }
    }
}
