import SwiftUI

struct WeatherRow: View {
    var logo: String
    var name: String
    var value: String
    
    var body: some View {
        
        HStack(alignment: .lastTextBaseline) {
            Spacer()
                //.frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 0)
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 0, height: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 0)
            Image(systemName: logo)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 25 : 35))
                .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 30 : 40)
                .padding(.trailing)
            VStack(alignment: .leading, spacing: 5) {
                Text(name)
                    .fontWeight(.light)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 15 : 25))
                Text(value)
                    .fontWeight(.bold)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 30))
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer()
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 0, height: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 0)
        }
    }
}

struct WeatherRow_Previews: PreviewProvider {
    static var previews: some View {
        WeatherRow(logo: "thermometer", name: "Feels like", value: "8°")
    }
}
