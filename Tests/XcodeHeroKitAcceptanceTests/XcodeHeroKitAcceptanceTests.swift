import Foundation
import Path
import TSCBasic
import XCTest
import SwiftTerminal

@testable import XcodeHeroKit

final class XcodeHeroKitAcceptanceTests: XCTestCase {
    func test_build_command() async throws {
        try await withTemporaryDirectory { tmpDir in
            /// Given
            let fixtureDirectory = try self.copyFixture(into: tmpDir)
            let xcodeprojPath = fixtureDirectory.appending(component: "Fixture.xcodeproj")
            let arguments = [xcodeprojPath.pathString, "--scheme", "Fixture"]
            let stdoutPipeline = TestStandardOutput()
            let context = XcodeHeroContext(standardPipelines: StandardPipelines(output: stdoutPipeline))

            // When
            try await BuildCommand.parse(arguments).run(context: context)
            
            // Then
            let containsOutput = await stdoutPipeline.output.contains("✓ The build of the scheme Fixture from project project \(xcodeprojPath.pathString) completed successfully")
            XCTAssertTrue(containsOutput)
        }
    }

    private func copyFixture(into: TSCBasic.AbsolutePath) throws -> Path.AbsolutePath {
        let fixtureDirectory = (try Path.AbsolutePath(validating: #file)).parentDirectory.parentDirectory.parentDirectory
            .appending(component: "Fixture")
        let outputPath = into.appending(component: "Fixture")
        try FileManager.default.copyItem(atPath: fixtureDirectory.pathString, toPath: outputPath.pathString)
        return try! Path.AbsolutePath(validating: outputPath.pathString)
    }
    
    actor TestStandardOutput: StandardPipelining {
        var output: String = ""
        
        func write(content: String) {
            output.append(content)
        }
    }
}
