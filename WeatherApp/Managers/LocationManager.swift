import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // Creating an instance of CLLocationManager, the framework we use to get the coordinates
    let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var isLoading = false
    @Published var cityName: String?
    @Published var locationUpdated = false

    
    override init() {
        super.init()
        
        // Assigning a delegate to our CLLocationManager instance
        manager.delegate = self
    }
    
    func requestLocation() {
        isLoading = true
        manager.requestLocation()
    }
    
    func requestLocationByCity(city: String, presentingViewController: UIViewController) async throws {
        await MainActor.run { isLoading = true }
        

        // We can't use await in defer so we wrapped it in task
        defer {
            Task { await MainActor.run { isLoading = false } }
        }

        let city = city.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed)!
        var cityName = city
            if cityName == "Łódź Voivodeship" {
                cityName = "Łódź"
            }
        guard let url = URL(string: "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName)&limit=1&appid=f1713ff8f3edf7b7afd6a48d1bd6c659&units=metric")
        else {
            fatalError("Missing URL")
        }
        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        
        let decodedData = try JSONDecoder().decode([OpenWAPICityData].self, from: data)
        
        var clCoords = CLLocationCoordinate2D();
        if decodedData.count == 0 {
            throw NSError(domain: "com.example.app", code: 404, userInfo: [NSLocalizedDescriptionKey: "City not found"])
        }
        
        clCoords.latitude = decodedData[0].lat;
        clCoords.longitude = decodedData[0].lon;
        
        // MainActor.run executes code on main thread cuz only main thread is allowed to make changes to ui
        await MainActor.run { [clCoords] in
            location = clCoords
        }
    }
    
    // Set the location coordinates to the location variable
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        isLoading = false

        guard let location = locations.last else { return }
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            let city = placemark.locality
            DispatchQueue.main.async {
                self.cityName = city
            }
            print(city ?? "def value locationmanager")
        }
    }
    
    // This function will be called if we run into an error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location", error)
        isLoading = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let presentingViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                presentingViewController.dismiss(animated: true, completion: nil)
            })
            presentingViewController.present(alert, animated: true, completion: nil)
        }
    }
}

struct OpenWAPICityData : Decodable {
    public var lat: Double;
    public var lon: Double;
}
