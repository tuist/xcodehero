import Darwin
import Foundation
import Path
import SwiftTerminal

protocol Context: Actor {
    var isInteractive: Bool { get set }
    var shouldColor: Bool { get set }
    var envVariables: [String: String] { get }
    var currentWorkingDirectory: AbsolutePath { get }
    var cacheDirectory: AbsolutePath { get }
    var homeDirectory: AbsolutePath { get }
    var standardPipelines: StandardPipelines { get }
}

actor XcodeHeroContext: Context {
    var isInteractive: Bool
    var shouldColor: Bool
    let envVariables: [String: String]
    let currentWorkingDirectory: AbsolutePath
    let cacheDirectory: AbsolutePath
    let homeDirectory: AbsolutePath
    let standardPipelines: StandardPipelines

    init(
        isInteractive: Bool = XcodeHeroContext.defaultIsInteractive(),
        shouldColor: Bool = XcodeHeroContext.defaultShouldColor(),
        envVariables: [String: String] = XcodeHeroContext.defaultEnvVariables(),
        currentWorkingDirectory: AbsolutePath = XcodeHeroContext.defaultCurrentWorkingDirectory(),
        cacheDirectory: AbsolutePath = XcodeHeroContext.defaultCacheDirectory(),
        homeDirectory: AbsolutePath = XcodeHeroContext.defaultHomeDirectory(),
        standardPipelines: StandardPipelines = XcodeHeroContext.defaultStandardPipelines()
    ) {
        self.isInteractive = isInteractive
        self.shouldColor = shouldColor
        self.envVariables = envVariables
        self.currentWorkingDirectory = currentWorkingDirectory
        self.cacheDirectory = cacheDirectory
        self.homeDirectory = homeDirectory
        self.standardPipelines = standardPipelines
    }
    
    static func defaultCacheDirectory() -> AbsolutePath {
        if let xdgCacheHome = ProcessInfo.processInfo.environment["XDG_CACHE_HOME"] {
            try! AbsolutePath(validating: xdgCacheHome)
        } else {
            (try! AbsolutePath(validating: FileManager.default.homeDirectoryForCurrentUser.path())).appending(components: [
                ".cache",
                "xcodehero",
            ])
        }
    }
    
    static func defaultStandardPipelines() -> StandardPipelines {
        return StandardPipelines()
    }
    
    static func defaultHomeDirectory() -> Path.AbsolutePath {
        return try! AbsolutePath(validating: FileManager.default.homeDirectoryForCurrentUser.path())
    }

    static func defaultCurrentWorkingDirectory() -> Path.AbsolutePath {
        try! AbsolutePath(validating: FileManager.default.currentDirectoryPath)
    }

    static func defaultIsInteractive() -> Bool {
        ProcessInfo.processInfo.environment["XCODEHERO_NO_TTY"] != nil || ProcessInfo.processInfo.arguments.contains("--no-tty")
    }

    static func defaultShouldColor() -> Bool {
        ProcessInfo.processInfo.environment["XCODEHERO_NO_COLOR"] != nil || ProcessInfo.processInfo.arguments
            .contains("--no-color")
    }

    static func defaultEnvVariables() -> [String: String] {
        ProcessInfo.processInfo.environment
    }
}
