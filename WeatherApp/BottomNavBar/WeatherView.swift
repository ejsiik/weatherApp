import SwiftUI
import CoreLocation
import Network
import CoreLocationUI

func convertTimestamp(_ timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    dateFormatter.dateStyle = .none
    dateFormatter.timeZone = TimeZone.current
    let localDate = dateFormatter.string(from: date)
    return localDate
}

struct WeatherView: View {
    // Replace YOUR_API_KEY in WeatherManager with your own API key for the app to work
    var weather: ResponseBody
    @EnvironmentObject var sharedText: SharedText
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @StateObject var viewModel = WeatherViewModel()
    @State private var showAlert = false
    
    var body: some View {
        let weatherDescriptions = [
            "Clear": ("Clear", "sun.max.fill"),
            "Clouds": ("Cloudy", "cloud.fill"),
            "Drizzle": ("Drizzle", "cloud.drizzle.fill"),
            "Rain": ("Rain", "cloud.rain.fill"),
            "Thunderstorm": ("Thunderstorm", "cloud.bolt.fill"),
            "Snow": ("Snow", "cloud.snow.fill"),
            "Mist": ("Mist", "cloud.fog.fill"),
            "Smoke": ("Smoke", "smoke.fill"),
            "Haze": ("Haze", "sun.haze.fill"),
            "Dust": ("Dust", "sun.dust.fill"),
            "Fog": ("Fog", "cloud.fog.fill"),
            "Sand": ("Sandstorm", "cloud.hail.fill"),
            "Ash": ("Volcanic Ash", "smoke.fill"),
            "Squall": ("Squall", "wind.snow"),
            "Tornado": ("Tornado", "tornado"),
        ]
        
        let weatherCode = (sharedText.text == "no" ? weather.weather[0].main : weatherViewModel.weather?.weather[0].main) ?? weather.weather[0].main
        let (weatherDescription, weatherIcon) = weatherDescriptions[weatherCode] ?? ("Nieznana", "questionmark")
        //NavigationView{
            ScrollView{
                ZStack(alignment: .leading) {
                    VStack {
                        VStack(alignment: .leading, spacing: 5) {
                            if(sharedText.text == "no")
                            {
                                Text(weather.name)
                                    .bold()
                                
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 40))
                            } else {
                                Text(weatherViewModel.weather?.name ?? "")
                                    .bold()
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 40))
                            }
                            Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))")
                                .fontWeight(.light)
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                            .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 40)
                        
                        VStack {
                            HStack {
                                VStack(spacing: 30) {
                                    Image(systemName: weatherIcon)
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 50))
                                    Text(weatherDescription)
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20))
                                }
                                .frame(width: 150, alignment: .leading)
                                
                                Spacer()
                                if(sharedText.text == "no") {
                                    Text(weather.main.temp.roundDouble() + "°")
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 140 : 80))
                                        .fontWeight(.bold)
                                        .padding()
                                } else {
                                    Text("\(weatherViewModel.weather?.main.temp.roundDouble() ?? "0")°")
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 140 : 80))
                                        .fontWeight(.bold)
                                        .padding()
                                }
                            }
                            Spacer()
                                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 40)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Weather now")
                                    .bold()
                                    .padding(.bottom)
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20))
                                
                                HStack {
                                    if(sharedText.text == "no")
                                    {
                                        WeatherRow(logo: "thermometer", name: "Min temp", value: (weather.main.tempMin.roundDouble() + ("°")))
                                        Spacer()
                                        WeatherRow(logo: "thermometer", name: "Max temp", value: (weather.main.tempMax.roundDouble() + "°"))
                                    }
                                    else {
                                        WeatherRow(logo: "thermometer", name: "Min temp", value: "\(weatherViewModel.weather?.main.tempMin.roundDouble() ?? "0")°")
                                        Spacer()
                                        WeatherRow(logo: "thermometer", name: "Max temp", value: "\(weatherViewModel.weather?.main.tempMax.roundDouble() ?? "0")°")
                                    }
                                }
                                
                                HStack {
                                    if(sharedText.text == "no")
                                    {
                                        WeatherRow(logo: "wind", name: "Wind speed", value: (weather.wind.speed.roundDouble() + " m/s"))
                                        Spacer()
                                        WeatherRow(logo: "humidity", name: "Humidity", value: "\(weather.main.humidity.roundDouble())%")
                                    }
                                    else {
                                        WeatherRow(logo: "wind", name: "Wind speed", value: "\(weatherViewModel.weather?.wind.speed.roundDouble() ?? "0") m/s")
                                        Spacer()
                                        WeatherRow(logo: "humidity", name: "Humidity", value: "\(weatherViewModel.weather?.main.humidity.roundDouble() ?? "0")%")
                                    }
                                }
                                
                                HStack {
                                    if(sharedText.text == "no")
                                    {
                                        WeatherRow(logo: "barometer", name: "Pressure", value: (weather.main.pressure.roundDouble() + " hPa"))
                                        Spacer()
                                        WeatherRow(logo: "thermometer.sun", name: "Feels like", value: "\(weather.main.feelsLike.roundDouble())°")
                                    }
                                    else {
                                        WeatherRow(logo: "barometer", name: "Pressure", value: "\(weatherViewModel.weather?.main.pressure.roundDouble() ?? "0") hPa")
                                        Spacer()
                                        WeatherRow(logo: "thermometer.sun", name: "Feels like", value: "\(weatherViewModel.weather?.main.feelsLike.roundDouble() ?? "0")°")
                                    }
                                }
                                
                                HStack {
                                    if(sharedText.text == "no") {
                                        WeatherRow(logo: "sunrise", name: "Sunrise", value: convertTimestamp(weather.sys.sunrise))
                                        Spacer()
                                        WeatherRow(logo: "sunset", name: "Sunset", value: convertTimestamp(weather.sys.sunset))
                                    } else {
                                        WeatherRow(logo: "sunrise", name: "Sunrise", value: convertTimestamp(weatherViewModel.weather?.sys.sunrise ?? 0))
                                        Spacer()
                                        WeatherRow(logo: "sunset", name: "Sunset", value: convertTimestamp(weatherViewModel.weather?.sys.sunset ?? 0))
                                    }
                                }
                                
                                HStack {
                                    if(sharedText.text == "no")
                                    {
                                        WeatherRow(logo: "cloud.rain.fill", name: "Chance of rain", value: ("\(weather.clouds.all)%"))
                                        Spacer()
                                        WeatherRow(logo: "eye.fill", name: "Visibility", value: ("\(weather.visibility/1000) km"))
                                    }
                                    else {
                                        WeatherRow(logo: "cloud.rain.fill", name: "Chance of rain", value: "\(weatherViewModel.weather?.clouds.all ?? 0)%")
                                        Spacer()
                                        WeatherRow(logo: "eye.fill", name: "Visibility", value: "\((weatherViewModel.weather?.visibility ?? 0) / 1000) km")
                                    }
                                }
                                
                            }
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 400, alignment: .leading)
                            .padding()
                            .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                            .background(.white)
                            .cornerRadius(20)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 80 : 0)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .edgesIgnoringSafeArea(.bottom)
                    .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                    .preferredColorScheme(.dark)
                    
                    VStack {
                        HStack {
                            Spacer()
                            LocationButton() {
                                locationManager.requestLocation()
                                guard let location = locationManager.location else {
                                    print("Error getting current location")
                                    return
                                }
                                
                                Task {
                                    await weatherViewModel.getWeatherForCoordinates(latitude: location.latitude, longitude: location.longitude)
                                }
                                
                                if let cityName = locationManager.cityName {
                                    print(cityName)
                                    sharedText.text = cityName
                                    locationManager.locationUpdated = true
                                }
                            }
                            .cornerRadius(30)
                            .symbolVariant(.fill)
                            .foregroundColor(.white)
                            .labelStyle(.iconOnly)
                            
                            /*Button(action: {
                                locationManager.requestLocation()
                                
                                guard let location = locationManager.location else {
                                    print("Error getting current location")
                                    return
                                }
                                
                                Task {
                                    await weatherViewModel.getWeatherForCoordinates(latitude: location.latitude, longitude: location.longitude)
                                }
                                
                                if let cityName = locationManager.cityName {
                                    print(cityName)
                                    sharedText.text = cityName
                                    locationManager.locationUpdated = true
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 25 : 40))
                                    .foregroundColor(.white)
                            }*/
                        }
                        .padding(25)
                        Spacer()
                    }
                }
                
            }
            .onAppear {
                Task {
                    if(sharedText.text == "no")
                    {
                        print(sharedText.text+"model")
                        print(locationManager.location ?? "xd")
                    } else {
                        print(sharedText.text+"viewmodel")
                        await weatherViewModel.getWeatherForCity(city: sharedText.text)
                    }
                }
            }
            .onReceive(locationManager.$locationUpdated) { updated in
                if updated {
                    Task {
                        if(sharedText.text == "no")
                        {
                            print(locationManager.location ?? "xd")
                        } else {
                            print(sharedText.text+"ONRECEIVE")
                            await weatherViewModel.getWeatherForCity(city: sharedText.text)
                        }
                    }
                    locationManager.locationUpdated = false
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("No internet connection"),
                    message: Text("Setting default location."),
                    dismissButton: .default(Text("OK")) {
                        showAlert = false
                    }
                )
            }
            .onAppear {
                checkInternetConnection()
            }
        }
    
    
    func checkInternetConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                showAlert = false
            } else {
                showAlert = true
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
