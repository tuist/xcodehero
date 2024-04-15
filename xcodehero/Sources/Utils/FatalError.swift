import Foundation

protocol FatalError: Error, CustomStringConvertible {
    var nextSteps: [String] { get }
}
