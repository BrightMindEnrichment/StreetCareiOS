import CoreLocation
import FirebaseFirestore
import GoogleMaps

class MapViewModel: ObservableObject {
    @Published var visitLogs: [(location: CLLocationCoordinate2D, title: String, description: String?)] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    weak var mapView: GMSMapView?
    private let geocoder = CLGeocoder()
    
    @MainActor
    func fetchMarkers() async {
        isLoading = true
        let db = Firestore.firestore()
        var results: [(CLLocationCoordinate2D, String, String?)] = []

        do {
            let snapshot = try await db.collection("visitLogWebProd")
                .whereField("public", isEqualTo: true)
                .order(by: "dateTime", descending: true)
                .limit(to: 50)
                .getDocuments()

            let documents = snapshot.documents
            print("📦 Found \(documents.count) recent public visit logs")

            for (index, doc) in documents.enumerated() {
                let data = doc.data()
                guard
                    let street = data["street"] as? String,
                    let city = data["city"] as? String,
                    let state = data["state"] as? String,
                    let zipcode = data["zipcode"] as? String,
                    let title = data["whatGiven"] as? [String],
                    !title.isEmpty else {
                        print("⚠️ [\(index)] Skipped due to missing fields")
                        continue
                    }

                let fullAddress = "\(street), \(city), \(state) \(zipcode)"
                let logTitle = title.joined(separator: ", ")
                let description = data["description"] as? String

                try await Task.sleep(nanoseconds: 1_000_000_000) // Respect rate limit

                do {
                    let coordinate = try await geocodeAddress(fullAddress)
                    results.append((coordinate, logTitle, description))
                    print("📍 [\(index)] Geocoded: \(fullAddress)")
                } catch {
                    print("❌ [\(index)] Failed to geocode \(fullAddress): \(error.localizedDescription)")
                }
            }

            self.visitLogs = results
            print("✅ Loaded \(results.count) geocoded visit logs.")
        } catch {
            self.error = error
            print("❌ Firestore fetch failed: \(error.localizedDescription)")
        }

        isLoading = false
    }

    
    private func geocodeAddress(_ address: String) async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let coordinate = placemarks?.first?.location?.coordinate {
                    continuation.resume(returning: coordinate)
                } else {
                    continuation.resume(throwing: NSError(domain: "Geocoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "No coordinates found."]))
                }
            }
        }
    }
}
