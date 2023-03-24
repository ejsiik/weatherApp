import SwiftUI

struct WeatherView: View {
    // Replace YOUR_API_KEY in WeatherManager with your own API key for the app to work
    var weather: ResponseBody
    @EnvironmentObject var sharedText: SharedText
    
    var body: some View {
        ScrollView{
            Button("Print") {
                Task { print(sharedText.text) }
            }
            ZStack(alignment: .leading) {
                VStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(weather.name)
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
                                
                                Text("\(weather.weather[0].main)")
                            }
                            .frame(width: 150, alignment: .leading)
                            
                            Spacer()
                            
                            Text(weather.main.temp.roundDouble() + "°")
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
                                WeatherRow(logo: "thermometer.low", name: "Min temp", value: (weather.main.tempMin.roundDouble() + ("°")))
                                Spacer()
                                WeatherRow(logo: "thermometer.high", name: "Max temp", value: (weather.main.tempMax.roundDouble() + "°"))
                            }
                            
                            HStack {
                                WeatherRow(logo: "wind", name: "Wind speed", value: (weather.wind.speed.roundDouble() + " m/s"))
                                Spacer()
                                WeatherRow(logo: "humidity", name: "Humidity", value: "\(weather.main.humidity.roundDouble())%")
                            }
                            
                            HStack {
                                WeatherRow(logo: "pressure", name: "Pressure", value: (weather.main.pressure.roundDouble() + " hPa"))
                                Spacer()
                                WeatherRow(logo: "thermometer.sun", name: "Feels like", value: "\(weather.main.feelsLike.roundDouble())°")
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
            
        }
    }
    
}
/*struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(weather: previewWeather)
    }
}*/
