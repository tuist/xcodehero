import Foundation
import Path

extension AbsolutePath {
    func glob(pattern: String) -> [AbsolutePath] {
        Glob(pattern: appending(try! RelativePath(validating: pattern)).pathString).paths
            .map { try! AbsolutePath(validating: $0) }
    }

    static var currentWorkingDirectory: AbsolutePath {
        try! AbsolutePath(validating: FileManager.default.currentDirectoryPath)
    }
}
