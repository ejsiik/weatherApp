import Foundation
import CoreLocation

class FavouriteLocationManager: ObservableObject {
    @Published var locations = [Location]()
    @Published var updated = false
    
    init() {
        loadLocations()
    }
    
    func loadLocations() {
        guard let locationsData = UserDefaults.standard.data(forKey: "locations") else {
            return
        }
        let locations = try? JSONDecoder().decode([Location].self, from: locationsData)
        self.locations = locations ?? []
    }
    
    func addLocation(_ locationName: String) {
        guard !locationName.isEmpty else { return }
        if locations.contains(where: { $0.name.lowercased() == locationName.removingPercentEncoding?.lowercased().replacingOccurrences(of: "+", with: " ")}) {
            // Location is already in the list
            return
        }
        fetchWeatherData(forCity: locationName)
    }
    
    private func fetchWeatherData(forCity city: String) {
        let apiKey = "f1713ff8f3edf7b7afd6a48d1bd6c659"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    let newLocation = Location(name: weatherData.name)
                    self.locations.append(newLocation)
                    self.updateLocations()
                }
            } catch {
                print("Error decoding weather data: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func saveLocations() {
        let locationsData = try? JSONEncoder().encode(locations)
        UserDefaults.standard.set(locationsData, forKey: "locations")
    }
    
    private func updateLocations() {
        let uniqueLocations = Dictionary(grouping: locations, by: { $0.name })
            .values
            .compactMap { $0.first }
        self.locations = uniqueLocations
        self.locations.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        self.saveLocations()
    }
}

struct Location: Codable, Identifiable {
    var id = UUID()
    let name: String
}

struct WeatherData: Codable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }
}
