import Foundation
import CoreLocation

struct Task: Identifiable, Hashable {
    let id: UUID
    var title: String
    var details: String

    var imageData: Data?
    var latitude: Double?
    var longitude: Double?
    var locationName: String?

    var isCompleted: Bool {
        imageData != nil
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(id: UUID = UUID(), title: String, details: String) {
        self.id = id
        self.title = title
        self.details = details
        self.imageData = nil
        self.latitude = nil
        self.longitude = nil
    }
}
