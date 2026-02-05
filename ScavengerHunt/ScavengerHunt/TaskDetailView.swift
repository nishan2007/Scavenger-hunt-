import SwiftUI
import _Concurrency
import PhotosUI
import MapKit
import CoreLocation
import ImageIO
import UniformTypeIdentifiers

struct TaskDetailView: View {
    @EnvironmentObject var store: TaskStore
    let taskID: Task.ID

    @State private var selectedItem: PhotosPickerItem?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var errorMessage: String?

    private var task: Task? {
        guard let idx = store.index(for: taskID) else { return nil }
        return store.tasks[idx]
    }
    
    private func defaultRegion() -> MKCoordinateRegion {
        // Default region so the map is always visible (Miami area)
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    }
    
    private func locationFromImageMetadata(_ data: Data) -> CLLocation? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let gps = props[kCGImagePropertyGPSDictionary] as? [CFString: Any]
        else {
            return nil
        }

        // GPSLatitude/GPSLongitude are usually numbers. Refs determine sign.
        guard let lat = gps[kCGImagePropertyGPSLatitude] as? Double,
              let lon = gps[kCGImagePropertyGPSLongitude] as? Double
        else {
            return nil
        }

        let latRef = (gps[kCGImagePropertyGPSLatitudeRef] as? String)?.uppercased()
        let lonRef = (gps[kCGImagePropertyGPSLongitudeRef] as? String)?.uppercased()

        let signedLat = (latRef == "S") ? -abs(lat) : abs(lat)
        let signedLon = (lonRef == "W") ? -abs(lon) : abs(lon)

        return CLLocation(latitude: signedLat, longitude: signedLon)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(task?.title ?? "")
                    .font(.title2)
                    .bold()

                Text(task?.details ?? "")
                    .foregroundStyle(.secondary)

                if let data = task?.imageData,
                   let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("Attach Photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Map(position: $cameraPosition) {
                    if let coordinate = task?.coordinate,
                       let data = task?.imageData,
                       let image = UIImage(data: data) {
                        Annotation("", coordinate: coordinate) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.white, lineWidth: 2)
                                )
                                .shadow(radius: 4)
                        }
                    }
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    if task?.coordinate == nil {
                        Text(task?.isCompleted == true
                             ? "No location metadata found in this photo."
                             : "Attach a photo to show its location.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .onAppear {
                if case .automatic = cameraPosition {
                    cameraPosition = .region(defaultRegion())
                }
            }
        }
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            _Concurrency.Task {
                await attachPhoto(newItem)
            }
        }
    }

    @MainActor
    private func attachPhoto(_ item: PhotosPickerItem) async {
        do {
            errorMessage = nil

            // 1) Load image data first
            guard let data = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "Could not load image"
                return
            }

            // 2) Try to get location from Photos asset (best case)
            let assetId = item.itemIdentifier
            var location: CLLocation? = nil

            if let assetId {
                location = await store.locationFromAssetIdentifier(assetId)
            } else {
                // If there's no asset identifier, Photos may be in Limited mode or simulator may not provide it.
                errorMessage = "Could not read the photo's asset identifier. Trying metadata fallback..."
            }

            // 3) Fallback: try to read GPS directly from the image metadata
            if location == nil {
                location = locationFromImageMetadata(data)
            }

            // 4) Save to task
            var placeName: String? = nil
            if let location {
                if let placemark = try? await CLGeocoder().reverseGeocodeLocation(location).first {
                    // Prefer a true location label (City, State). Fall back to address if needed.
                    let city = placemark.locality
                    let state = placemark.administrativeArea
                    let cityState = [city, state].compactMap { $0 }.joined(separator: ", ")

                    if !cityState.isEmpty {
                        placeName = cityState
                    } else if let street = placemark.thoroughfare {
                        placeName = street
                    } else if let name = placemark.name {
                        placeName = name
                    }
                }
            }

            store.completeTask(taskID: taskID, imageData: data, location: location, locationName: placeName)

            // 5) Update map
            if let coordinate = location?.coordinate {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
                errorMessage = nil
            } else {
                cameraPosition = .region(defaultRegion())
                errorMessage = "No GPS location found for this image. Use a photo taken with Location Services ON (and avoid screenshots/downloaded images)."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
