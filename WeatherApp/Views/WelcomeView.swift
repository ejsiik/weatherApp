import SwiftUI
import CoreLocationUI
import UIKit

struct WelcomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var locationName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    func search(city: String) async {
        locationManager.isLoading = true
        do {
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }),
               let windowScene = window.windowScene {
                try await locationManager.requestLocationByCity(city: city, presentingViewController: (windowScene.windows.first?.rootViewController)!)
            }
        } catch let error as NSError {
            await MainActor.run {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
        locationManager.isLoading = false
    }

    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("Welcome to the Weather App")
                    .bold()
                    .font(.title)
                
                Text("Please share your current location to get the weather in your area")
                    .padding()
            }
            .multilineTextAlignment(.center)
            .padding()
            
            
            // LocationButton from CoreLocationUI framework imported above, allows us to requestionLocation
            VStack{
                LocationButton(.shareCurrentLocation) {
                    locationManager.requestLocation()
                }
                .cornerRadius(30)
                .symbolVariant(.fill)
                .foregroundColor(.white)
                
                Text("or").padding()
                
                HStack {
                    TextField("Enter city name", text: $locationName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .fixedSize()
                    Button("Search") {
                        let replaced = (locationName as NSString).replacingOccurrences(of: " ", with: "+")
                        let correct = replaced.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                        if !correct.isEmpty {
                            Task { await search(city: correct)
                                locationName = ""
                            }
                        }
                    }
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
