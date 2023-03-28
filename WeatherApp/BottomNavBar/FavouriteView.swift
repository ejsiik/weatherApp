import SwiftUI
import CoreLocation
import UIKit
import Network

extension String {
    func cutSpaces(using chRcterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: chRcterSet)
    }
}

struct FavouriteView: View {
    @State private var locationName = ""
    @State private var locations: [String] = []
    @AppStorage("locationsData") private var locationsData: String = ""
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject var sharedText: SharedText
    @FocusState private var isFocused: Bool
    @Binding var selection: Int
    @State private var showAlert = false
    @State private var showInternetAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if(showInternetAlert == false) {
                Text("Locations")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 40))
                    .fontWeight(.bold)
                    .padding(UIDevice.current.userInterfaceIdiom == .pad ? 80 : 20)
                
                List {
                    ForEach(locations, id: \.self) { location in
                        Text(location)
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20))
                            .fontWeight(.medium)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(UIDevice.current.userInterfaceIdiom == .pad ? 30 : 10)
                            .foregroundColor(.primary)
                            .onTapGesture {
                                Task {
                                    await selectLocation(city: location)
                                    
                                }
                                print(location)
                                sharedText.text = location
                                DispatchQueue.main.async {
                                    selection = 1 // Switch to WeatherView
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    removeLocation(location: location)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                    }
                    .onDelete(perform: removeLocations)
                }
                .listStyle(.insetGrouped)
                .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .preferredColorScheme(.dark)
                
                Divider()
                
                HStack {
                    TextField("Enter city name", text: $locationName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isFocused)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                    Button(action: {
                        addLocation()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .frame(width: 50, height: 50)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                }
                .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .preferredColorScheme(.dark)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom)
            }
            else {
                ZStack {
                    Text("Error while loading weather")
                }
                .background(Color.black)
            }
        }
        .onAppear{
            checkInternetConnection()
            if let savedLocations = try? JSONDecoder().decode([String].self, from: Data(locationsData.utf8)) {
                locations = savedLocations
            }
        }
        .navigationBarItems(trailing: EditButton())
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
    }
    
    func selectLocation(city: String) async {
        var cityName = city
        if cityName == "Łódź Voivodeship" {
            cityName = "Łódź"
        }
        sharedText.text = cityName
        
        do {
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let hostingController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                
                try await locationManager.requestLocationByCity(city: cityName, presentingViewController: hostingController)
            }
        } catch let error as CLError {
            if error.code == .locationUnknown {
                print("Error: Invalid location provided")
                //showAlert = true
            } else {
                print("Error \(error)")
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func addLocation() {
        let trimmedLocation = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedLocation.isEmpty && !locations.contains(trimmedLocation) {
            let replaced = (trimmedLocation as NSString).replacingOccurrences(of: " ", with: "+")
            if !replaced.isEmpty {
                Task {
                    await search(city: replaced)
                    if !showAlert {
                        locations.append(replaced)
                        saveLocations()
                    }
                    locationName = ""
                }
            }
        }
    }

    func removeLocation(location: String) {
        if let index = locations.firstIndex(of: location) {
            withAnimation {
                locations.remove(at: index)
                saveLocations()
            }
        }
    }
    
    func removeLocations(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
    }
    
    private func saveLocations() {
        if let encodedLocations = try? JSONEncoder().encode(locations) {
            locationsData = String(data: encodedLocations, encoding: .utf8) ?? ""
        }
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
}
