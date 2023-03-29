import Foundation
import CoreLocation

class WeatherViewModel: ObservableObject {
    @Published var weather: ResponseBody?
    private let weatherManager = WeatherManager()
    @Published var forecastWeather: ForecastList?
    @Published var cityName: String?
    private var showGeocodeErrorAlert = false


    func getWeatherForCoordinates(latitude: Double, longitude: Double) async {
        do {
            let forecast = try await weatherManager.getForecastWeather(latitude: latitude, longitude: longitude)
            DispatchQueue.main.async {
                self.forecastWeather = forecast
            }
        } catch {
            print("Error fetching weather data: \(error)")
        }
    }
    
    func getWeatherForCity(city: String) async {
        do {
            print(city+"getWeather")
            let coordinates = try await getCoordinates(forCity: city)
            let fetchedWeather = try await weatherManager.getCurrentWeather(latitude: coordinates.latitude, longitude: coordinates.longitude)
            DispatchQueue.main.async {
                self.weather = fetchedWeather
            }
        } catch {
            if let error = error as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.Code.geocodeFoundNoResult.rawValue {
                    print("No matching location found for city: \(city)")
                    DispatchQueue.main.async {
                        self.showGeocodeErrorAlert = true
                    }
                } else {
                    print("Error: \(error)")
                }
            }
        }
    }


    func getCoordinates(forCity city: String) async throws -> CLLocationCoordinate2D {
        let geocoder = CLGeocoder()
        let locations = try await geocoder.geocodeAddressString(city)
        guard let firstLocation = locations.first,
              let coordinate = firstLocation.location?.coordinate else {
            throw NSError(domain: "com.example.myapp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to find coordinates for city"])
        }
        return coordinate
    }
    
    var sunriseTime: Date? {
        if let unixTime = weather?.sys.sunrise {
            return Date(timeIntervalSince1970: Double(unixTime))
        }
        return nil
    }

    var sunsetTime: Date? {
        if let unixTime = weather?.sys.sunset {
            return Date(timeIntervalSince1970: Double(unixTime))
        }
        return nil
    }

}
