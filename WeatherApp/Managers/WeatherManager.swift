import Foundation
import CoreLocation

class WeatherManager {
    var weekdayFormatter = WeekdayFormatter()
    
    // HTTP request to get the current weather depending on the coordinates we got from LocationManager
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody {
        // Replace YOUR_API_KEY in the link below with your own
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=f1713ff8f3edf7b7afd6a48d1bd6c659&units=metric") else { fatalError("Missing URL") }


        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        
        let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)

        return decodedData
    }
    
    func getForecastWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ForecastList {
        // Replace YOUR_API_KEY in the link below with your own
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=f1713ff8f3edf7b7afd6a48d1bd6c659&units=metric") else { fatalError("Missing URL") }


        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        
        let decodedData = try JSONDecoder().decode(OWAForecastList.self, from: data)
        
        var list: ForecastList = ForecastList(
            list: [],
            city: decodedData.city
        )
        
        var currentElement: ForecastListElement? = nil
        let calendar = Calendar.current
        
        decodedData.list.filter { el in
            return !calendar.isDateInToday(Date(timeIntervalSince1970: Double(el.dt)))
        }
        .forEach { el in
            let date = Date(timeIntervalSince1970: Double(el.dt))
            var weekday = weekdayFormatter.string(from: date);
            
            if (calendar.isDateInTomorrow(date)) {
                weekday = "Tomorrow"
            }
            
            if (currentElement?.weekday != weekday) {
                if (currentElement != nil) {
                    list.list.append(currentElement!)
                }
                currentElement = ForecastListElement(
                       id: weekday,
                       weekday: weekday,
                       main: el.main,
                       weather: el.weather,
                       wind: el.wind,
                       clouds: el.clouds,
                       pop: el.pop
                   )
               }
               
               if (el.main.temp > currentElement!.main.tempMax) {
                   currentElement!.main.temp_max = el.main.temp;
               }
               if (el.main.temp < currentElement!.main.tempMin) {
                   currentElement!.main.temp_min = el.main.temp;
               }
               if (el.main.humidity > currentElement!.main.humidity) {
                   currentElement!.main.humidity = el.main.humidity;
               }
           }
           
           if (currentElement != nil) {
               list.list.append(currentElement!)
           }
           
           return list
       }
       
   }

   struct ForecastList {
       var list: [ForecastListElement]
       var city: CityData
   }

   struct ForecastListElement: Identifiable {
       var id: String
       var weekday: String
       var main: MainResponse
       var weather: [WeatherResponse]
       var wind: WindResponse
       var clouds: CloudsResponse
       var pop: Double
   }

   struct OWAForecastList: Decodable {
       var list: [OWAForecastListElement]
       var city: CityData
   }

   struct CityData: Decodable {
       var id: Int32
       var name: String
   }

   struct OWAForecastListElement: Decodable, Identifiable {
       var id: Int64 {
           dt
       }
       var dt: Int64
       var main: MainResponse
       var weather: [WeatherResponse]
       var wind: WindResponse
       var clouds: CloudsResponse
       var pop: Double
   }

struct MainResponse: Decodable {
    var temp: Double
    var feels_like: Double
    var temp_min: Double
    var temp_max: Double
    var pressure: Double
    var humidity: Double
}

struct WeatherResponse: Decodable {
    var id: Double
    var main: String
    var description: String
    var icon: String
}

struct WindResponse: Decodable {
    var speed: Double
    var deg: Double
}

struct CoordinatesResponse: Decodable {
    var lon: Double
    var lat: Double
}

struct SysResponse: Decodable {
    var sunrise: Int
    var sunset: Int
}

struct CloudsResponse: Decodable {
    var all: Int
}

struct ResponseBody: Decodable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var main: MainResponse
    var name: String
    var wind: WindResponse
    var sys: SysResponse
    var clouds: CloudsResponse
    var visibility: Int
}

extension MainResponse {
    var Temp: Double {return temp}
    var feelsLike: Double { return feels_like }
    var tempMin: Double { return temp_min }
    var tempMax: Double { return temp_max }
}

extension Date {
    func formatTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
}

