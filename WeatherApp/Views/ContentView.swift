import SwiftUI
import CoreLocationUI
import CoreLocation


class SharedText: ObservableObject {
    @Published var text: String = "no"
}

struct ContentView: View {
    // Replace YOUR_API_KEY in WeatherManager with your own API key for the app to work
    @EnvironmentObject var locationManager: LocationManager
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    @State var selection = 1 // tabitem selection by default
    @StateObject private var sharedText = SharedText()
    @StateObject private var weatherViewModel = WeatherViewModel()
    

    var body: some View {
        VStack {
            if let location = locationManager.location {
                if let weather = weather {
                    TabView(selection: $selection) {
                        ForecastView()
                            .tabItem {
                                Label("Forecast", systemImage: "location")
                            }
                            .tag(0)
                        
                        WeatherView(weather: weather)
                            .environmentObject(sharedText)
                            .environmentObject(locationManager)
                            .environmentObject(weatherViewModel)
                            .tabItem {
                                Label("Weather", systemImage: "sun.max")
                            }
                            .tag(1)
                        
                        FavouriteView(selection: $selection)
                            .environmentObject(sharedText)
                            .tabItem {
                                Label("Favorites", systemImage: "heart.fill")
                            }
                            .tag(2)
                    }
                    .accentColor(.white)
                    .background(Color(UIColor.systemBackground))
                    //.tabViewStyle(PageTabViewStyle())
                } else {
                    // Dodać info dla użytkownika że pobrano dane offline!!!!!!!!!!!
                    LoadingView()
                        .task {
                            do {
                                weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                            } catch {
                                print("Error getting weather: \(error)")
                                let url = Bundle.main.url(forResource: "weatherData", withExtension: "json")!
                                do {
                                    let data = try Data(contentsOf: url)
                                    weather = try JSONDecoder().decode(ResponseBody.self, from: data)
                                    
                                } catch {
                                    print("Error parsing local weather data: \(error)")
                                }
                            }
                        }
                }
            } else {
                if locationManager.isLoading {
                    LoadingView()
                } else {
                    WelcomeView()
                        .environmentObject(locationManager)
                }
            }
        }
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

