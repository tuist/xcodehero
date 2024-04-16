import Foundation
import INIParser

struct ConfigFiles {
    let local: [String: String]?
    let user: [String: String]?
    let system: [String: String]?
}
