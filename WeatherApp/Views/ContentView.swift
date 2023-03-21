import SwiftUI
import CoreLocationUI
import CoreLocation

struct ContentView: View {
    // Replace YOUR_API_KEY in WeatherManager with your own API key for the app to work
    @StateObject var locationManager = LocationManager()
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    @State private var selection = 1 // tabitem selection by default
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                if let weather = weather {
                    TabView(selection: $selection) {
                        View1()
                            .tabItem{
                                Image(systemName: "location")
                            }.tag(0)
                        WeatherView(weather: weather)
                            .tabItem{
                                Image(systemName: "sun.max")
                            }.tag(1)
                        View2(items: ["Item 1", "Item 2", "Item 3"])
                            .tabItem{
                                Image(systemName: "heart.fill")
                            }.tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle())
                } else {
                    LoadingView()
                        .task {
                            do {
                                weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                            } catch {
                                print("Error getting weather: \(error)")
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

