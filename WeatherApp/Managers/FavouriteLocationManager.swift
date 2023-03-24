import Foundation


class FavouriteLocationManager: ObservableObject {
    @Published var locations = [Location]()
    
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
        if locations.contains(where: { $0.name.lowercased() == locationName.lowercased() }) {
            // Location is already in the list
            return
        }
        fetchWeatherData(forCity: locationName)
    }

    // for what? xD
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
                    self.saveLocations()
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
}

struct Location: Codable, Identifiable {
    let id = UUID()
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
