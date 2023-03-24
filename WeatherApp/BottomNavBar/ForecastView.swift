import SwiftUI
import CoreLocation

struct ForecastView: View {
    @EnvironmentObject var locationManager: LocationManager
    var weatherManager = WeatherManager()
    @State var forecast: ForecastList?
    @State var isLoading = true;
    
    func loadWeatherForecast(location: CLLocationCoordinate2D) async {
    isLoading = true
        defer { isLoading = false }
        do {
            forecast = try await weatherManager.getForecastWeather(latitude: location.latitude, longitude: location.longitude)
        }
        catch {
            print(error)
            print("Error while fetching weather forecast")
        }
    }
    
    var body: some View {
        if (locationManager.location != nil && !locationManager.isLoading) {
            VStack {
                if(forecast != nil && !isLoading) {
                    Text("\(forecast!.city.name)").bold().font(.system(size: 24))
                    ForecastListView(forecast: forecast!)
                }
                else if (isLoading) {
                    LoadingView()
                }
                else {
                    Text("Error while loading weather")
                }
            }.onAppear {
                Task { await loadWeatherForecast(location: locationManager.location!) }
            }
        }
        else if (locationManager.isLoading) {
            LoadingView()
        }
        else {
            Text("Error while loading location")
        }
    }
}

struct ForecastView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView()
    }
}

