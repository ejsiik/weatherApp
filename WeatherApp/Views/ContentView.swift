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
                        View2()
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
                            do {
                             weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                            } catch {
                                print("Error getting weather: \(error)")
                            }
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

    /*var body: some View {
        VStack {
            if let location = locationManager.location {
                TabView(selection: $selection) {
                    View1()
                        .tabItem{
                            Image(systemName: "location")
                        }.tag(0)
                    if let weather = weather {
                        WeatherView(weather: weather)
                            .tabItem{
                                Image(systemName: "sun.max")
                            }.tag(1)
                    } else {
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
                    View2(items: ["Item 1", "Item 2", "Item 3"])
                        .tabItem{
                            Image(systemName: "heart.fill")
                        }.tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
            } else {
                if locationManager.isLoading {
                    LoadingView()
                } else {
                    WelcomeView()
                        .environmentObject(locationManager)
                }
            }
        }
        .onAppear {
            if locationManager.status == .notDetermined {
                $locationManager.requestAuthorization
            }
        }*/
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

