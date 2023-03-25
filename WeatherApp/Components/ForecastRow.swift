import SwiftUI

struct ForecastRow: View {
    var element: ForecastListElement
    var weekdayFormatter = WeekdayFormatter()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(element.weekday).font(.system(size: 28)).bold().padding([.trailing, .bottom, .top], 15)
            HStack {
                HStack {
                    Image(systemName: "thermometer")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("max/min temp")
                            //.font(.caption)
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 15))
                        
                        Text("\(element.maxTemp.roundDouble())° / \(element.minTemp.roundDouble())°")
                            .bold()
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 25))
                    }
                }
                Spacer()
                HStack {
                    Image(systemName: "humidity")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("humidity")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 15))
                        
                        Text("\(element.humidity.roundDouble())%")
                            .bold()
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 25))
                    }
                }
            }.padding([.bottom], 15)
        }
    }
}
