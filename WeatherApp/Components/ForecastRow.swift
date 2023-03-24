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
                        .font(.system(size: 40))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("max/min temp")
                            .font(.caption)
                        
                        Text("\(element.maxTemp.roundDouble())° / \(element.minTemp.roundDouble())°")
                            .bold()
                            .font(.system(size: 24))
                    }
                }
                Spacer()
                HStack {
                    Image(systemName: "humidity")
                        .font(.system(size: 40))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("humidity")
                            .font(.caption)
                        
                        Text("\(element.humidity.roundDouble())%")
                            .bold()
                            .font(.system(size: 24))
                    }
                }
            }.padding([.bottom], 15)
        }
    }
}
