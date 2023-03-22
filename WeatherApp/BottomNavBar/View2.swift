import SwiftUI

struct Location: Codable, Identifiable {
    let id: Int
    let name: String
    let longitude: Double?
    let latitude: Double?
}

struct WeatherData: Codable {
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
}

struct View2: View {
    @State var locations = [Location]()
    @State var cityName = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter city name", text: $cityName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    addLocation()
                }
            }.padding()
            List {
                ForEach(locations) { location in
                    Text(location.name)
                        .onTapGesture {
                            print(location.id)
                            fetchWeatherData(for: location)
                        }
                }
                .onDelete(perform: delete)
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=Gliwice&appid=f1713ff8f3edf7b7afd6a48d1bd6c659") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(Location.self, from: data)
                        DispatchQueue.main.async {
                            locations.append(result)
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    func addLocation() {
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=f1713ff8f3edf7b7afd6a48d1bd6c659") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let location = try decoder.decode(Location.self, from: data)
                        DispatchQueue.main.async {
                            if !locations.contains(where: { $0.name == location.name }) {
                                locations.append(location)
                            }
                        }
                        if let longitude = location.longitude, let latitude = location.latitude {
                            let weatherUrl = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=f1713ff8f3edf7b7afd6a48d1bd6c659")!
                            URLSession.shared.dataTask(with: weatherUrl) { data, response, error in
                                if let data = data {
                                    do {
                                        let decoder = JSONDecoder()
                                        let weatherData = try decoder.decode(WeatherData.self, from: data)
                                        print(weatherData)
                                    } catch {
                                        print(error)
                                    }
                                }
                            }.resume()
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    func delete(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
    }
    
    func fetchWeatherData(for location: Location) {
        if let longitude = location.longitude, let latitude = location.latitude {
            let weatherUrl = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=f1713ff8f3edf7b7afd6a48d1bd6c659")!
            URLSession.shared.dataTask(with: weatherUrl) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let weatherData = try decoder.decode(WeatherData.self, from: data)
                        print(weatherData)
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    struct View2_Previews: PreviewProvider {
        static var previews: some View {
            View2()
        }
    }
}
