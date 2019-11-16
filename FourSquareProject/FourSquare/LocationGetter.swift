import Foundation
import CoreLocation


struct GetLocation {
    static func getData(name: String, type: String) -> Data {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            fatalError("\(name) \(type) file not found")
        }
        let internalURL = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: internalURL)
            return data
        } catch {
            fatalError("An error has occured: \(error)")
        }
    }
}
