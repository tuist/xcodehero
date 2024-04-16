import Foundation
import Path

enum ProjectPath {
    case workspace(AbsolutePath)
    case project(AbsolutePath)
    
    var directory: AbsolutePath {
        switch self {
        case .project(let path):
            return path.parentDirectory
        case .workspace(let path):
            return path.parentDirectory
        }
    }
}
