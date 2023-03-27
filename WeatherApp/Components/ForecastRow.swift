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
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 15))
                        
                        Text("\(element.main.temp_max.roundDouble())° / \(element.main.temp_min.roundDouble())°")
                            .bold()
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 25))
                    }
                }
                Spacer()
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chance of rain")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 15))
                        
                        Text("\((element.pop * 100).roundDouble())%")
                            .bold()
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 25))
                    }
                }
            }.padding([.bottom], 15)
        }
    }
}
