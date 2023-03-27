import SwiftUI

struct ForecastListView: View {
    var forecast: ForecastList
    
    
    var body: some View {
        List {
            ForEach(forecast.list) { entry in
                NavigationLink(destination: ForecastDetailView(element: entry)) {
                    ForecastRow(element: entry)
            }
        }
    }
}
}
