import SwiftUI
import CoreLocationUI
import UIKit
import Network
import CoreLocation


struct WelcomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var locationName = ""
    @State private var showAlert = false
    @State private var showInternetAlert = false
    @State private var alertMessage = ""

    var body: some View {
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Welcome to the Weather App")
                        .bold()
                        .font(.title)
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.center)
                    
                    Text("Please share your current location to get the weather in your area")
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // LocationButton from CoreLocationUI framework imported above, allows us to requestionLocation
                VStack(spacing: 20){
                    LocationButton(.shareCurrentLocation) {
                        locationManager.requestLocation()
                    }
                    .cornerRadius(30)
                    .symbolVariant(.fill)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    
                    Text("or")
                    
                    HStack {
                        TextField("Enter city name", text: $locationName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.headline)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Button("Search") {
                            let replaced = (locationName as NSString).replacingOccurrences(of: " ", with: "+")
                            if !replaced.isEmpty {
                                Task { await search(city: replaced)
                                    locationName = ""
                                }
                            }
                        }
                        .font(.headline)
                        .foregroundColor(Color(.systemBlue))
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showInternetAlert) {
                        Alert(
                            title: Text("No internet connection"),
                            message: Text("Check your connection and try again or click Share Current Location button"),
                            dismissButton: .default(Text("OK")) {
                                showInternetAlert = false
                            }
                        )
                    }
            .onAppear {
                checkInternetConnection()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
            .preferredColorScheme(.dark)
    }
    
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
                print("alerat1")
            }
        }
        locationManager.isLoading = false
    }
    
    func checkInternetConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                showInternetAlert = false
            } else {
                showInternetAlert = true
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
