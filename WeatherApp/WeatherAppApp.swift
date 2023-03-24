import SwiftUI

@main
struct WeatherAppApp: App {		
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(LocationManager())
        }
    }
}
