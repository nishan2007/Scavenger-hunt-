import SwiftUI
import Combine
import Photos
import CoreLocation

@MainActor
final class TaskStore: ObservableObject {
    @Published var tasks: [Task] = [
        Task(title: "Find a Palm Tree", details: "Take a photo of a palm tree."),
        Task(title: "Something Blue", details: "Take a photo of something blue."),
        Task(title: "A Coffee Spot", details: "Take a photo at a coffee shop."),
        Task(title: "Street Art", details: "Take a photo of a mural."),
        Task(title: "Landmark", details: "Take a photo of a local landmark.")
    ]

    func index(for taskID: Task.ID) -> Int? {
        tasks.firstIndex { $0.id == taskID }
    }

    func completeTask(taskID: Task.ID, imageData: Data, location: CLLocation?, locationName: String?) {
        guard let idx = index(for: taskID) else { return }
        tasks[idx].imageData = imageData
        if let location {
            tasks[idx].latitude = location.coordinate.latitude
            tasks[idx].longitude = location.coordinate.longitude
        }
    }

    func locationFromAssetIdentifier(_ id: String?) async -> CLLocation? {
        guard let id else { return nil }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        return assets.firstObject?.location
    }
}
