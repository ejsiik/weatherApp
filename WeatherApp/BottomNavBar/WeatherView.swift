import SwiftUI

struct WeatherView: View {
    // Replace YOUR_API_KEY in WeatherManager with your own API key for the app to work
    var weather: ResponseBody
    @EnvironmentObject var sharedText: SharedText
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    
    var body: some View {
        ScrollView{
            ZStack(alignment: .leading) {
                VStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(weatherViewModel.weather?.name ?? "")
                            .bold()
                            .font(.title)
                        
                        Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))")
                            .fontWeight(.light)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            VStack(spacing: 20) {
                                Image(systemName: "cloud")
                                    .font(.system(size: 40))
                                
                                //("\(weather.weather[0].main)")
                                Text("\(weatherViewModel.weather?.weather[0].main ?? "")")
                            }
                            .frame(width: 150, alignment: .leading)
                            
                            Spacer()
                            
                            //Text(weather.main.temp.roundDouble() + "°")
                            Text("\(weatherViewModel.weather?.main.temp.roundDouble() ?? "0")°")
                                .font(.system(size: 100))
                                .fontWeight(.bold)
                                .padding()
                        }
                        
                        Spacer()
                            .frame(height:  80)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Weather now")
                                .bold()
                                .padding(.bottom)
                            
                            HStack {
                                WeatherRow(logo: "thermometer.low", name: "Min temp", value: "\(weatherViewModel.weather?.main.tempMin.roundDouble() ?? "0")°")
                                Spacer()
                                WeatherRow(logo: "thermometer.high", name: "Max temp", value: "\(weatherViewModel.weather?.main.tempMax.roundDouble() ?? "0")°")
                            }
                            
                            HStack {
                                WeatherRow(logo: "wind", name: "Wind speed", value: "\(weatherViewModel.weather?.wind.speed.roundDouble() ?? "0") m/s")
                                Spacer()
                                WeatherRow(logo: "humidity", name: "Humidity", value: "\(weatherViewModel.weather?.main.humidity.roundDouble() ?? "0")%")
                            }
                            
                            HStack {
                                WeatherRow(logo: "pressure", name: "Pressure", value: "\(weatherViewModel.weather?.main.pressure.roundDouble() ?? "0") hPa")
                                Spacer()
                                WeatherRow(logo: "thermometer.sun", name: "Feels like", value: "\(weatherViewModel.weather?.main.feelsLike.roundDouble() ?? "0")°")
                            }
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .padding(.bottom, 20)
                        .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                        .background(.white)
                        .cornerRadius(20)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .edgesIgnoringSafeArea(.bottom)
                .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .preferredColorScheme(.dark)
                
            }
    }.onAppear {
            Task {
                await weatherViewModel.getWeatherForCity(city: sharedText.text)
            }
        }
    }
}
/*struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(weather: previewWeather)
    }
}*/
