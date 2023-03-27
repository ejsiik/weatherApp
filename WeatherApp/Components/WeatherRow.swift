import SwiftUI

struct WeatherRow: View {
    var logo: String
    var name: String
    var value: String
    
    var body: some View {
        
        HStack(alignment: .lastTextBaseline) {
            Spacer()
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 0, height: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 0)
            let imageSize = UIDevice.current.userInterfaceIdiom == .phone ? 25 : 35
            Image(systemName: logo)
                .font(.system(size: CGFloat(imageSize)))
                .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 30 : 40)
                .padding(.trailing)
            VStack(alignment: .leading, spacing: 5) {
                Text(name)
                    .fontWeight(.light)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 15 : 25))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(value)
                    .fontWeight(.bold)
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 30))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .fixedSize(horizontal: false, vertical: true)
            .alignmentGuide(.lastTextBaseline, computeValue: { dimension in
                CGFloat(imageSize) * 0.8
            })
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
