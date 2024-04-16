import Foundation

protocol FatalError: Error, CustomStringConvertible {
    var context: String { get }
    var nextSteps: [String] { get }
}
