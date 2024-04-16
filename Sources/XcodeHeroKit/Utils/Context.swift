import Foundation
import Darwin
import Path

protocol Context: Actor {
    var isInteractive: Bool { get }
    var shouldColor: Bool { get }
    var envVariables: [String: String] { get }
    var currentWorkingDirectory: AbsolutePath { get }
    var cacheDirectory: AbsolutePath { get }
    var homeDirectory: AbsolutePath { get }
}

actor XcodeHeroContext: Context {
    
    let isInteractive: Bool
    let shouldColor: Bool
    let envVariables: [String: String]
    let currentWorkingDirectory: AbsolutePath
    let cacheDirectory: AbsolutePath
    let homeDirectory: AbsolutePath
    
    init(isInteractive: Bool,
         shouldColor: Bool,
         envVariables: [String: String],
         currentWorkingDirectory: AbsolutePath,
         cacheDirectory: AbsolutePath,
         homeDirectory: AbsolutePath) {
        self.isInteractive = isInteractive
        self.shouldColor = shouldColor
        self.envVariables = envVariables
        self.currentWorkingDirectory = currentWorkingDirectory
        self.cacheDirectory = cacheDirectory
        self.homeDirectory = homeDirectory
    }
    
    init() {
        self.isInteractive = !(ProcessInfo.processInfo.environment["NO_TTY"] != nil) || isatty(STDIN_FILENO) != 0
        self.shouldColor = !(ProcessInfo.processInfo.environment["NO_COLOR"] != nil)
        self.envVariables = ProcessInfo.processInfo.environment
        self.currentWorkingDirectory = try! AbsolutePath(validating: FileManager.default.currentDirectoryPath)
        self.homeDirectory = try! AbsolutePath(validating: FileManager.default.homeDirectoryForCurrentUser.path())
        self.cacheDirectory = if let xdgCacheHome = ProcessInfo.processInfo.environment["XDG_CACHE_HOME"] {
            try! AbsolutePath(validating: xdgCacheHome)
        } else {
            (try! AbsolutePath(validating: FileManager.default.homeDirectoryForCurrentUser.path())).appending(components: [".cache", "xcodehero"])
        }
    }
    
}
