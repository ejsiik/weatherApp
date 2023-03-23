import SwiftUI

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

class LocationManagerView2: ObservableObject {
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
            // Lokalizacja już istnieje na liście
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


struct View2: View {
    @State private var locationName = ""
    @StateObject private var locationManager = LocationManagerView2()

    var body: some View {
        VStack {
            List {
                ForEach(locationManager.locations) { location in
                    Text(location.name)
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                removeLocation(location: location)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                }
                .onDelete(perform: removeLocations)
            }
            HStack {
                TextField("Enter city name", text: $locationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    locationManager.addLocation(locationName)
                    locationName = ""
                }
            }.padding()
        }
        .navigationBarItems(trailing: EditButton())
    }

    func removeLocation(location: Location) {
        if let index = locationManager.locations.firstIndex(where: { $0.id == location.id }) {
            locationManager.locations.remove(at: index)
            locationManager.saveLocations()
        }
    }

    func removeLocations(at offsets: IndexSet) {
        locationManager.locations.remove(atOffsets: offsets)
        locationManager.saveLocations()
    }
    
    struct View2_Previews: PreviewProvider {
        static var previews: some View {
            View2()
        }
    }
}
