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
    @State private var favorites: Set<String> = []
    @AppStorage("locationsData") private var locationsData: String = ""
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject var sharedText: SharedText
    @FocusState private var isFocused: Bool
    @Binding var selection: Int
    @State private var showAlert = false
    @State private var showInternetAlert = false
    @State private var alertMessage = ""
    @State private var draggingIndexSet: IndexSet?


    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if(showInternetAlert == false) {
                Text("Locations")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 40))
                    .fontWeight(.bold)
                    .padding(UIDevice.current.userInterfaceIdiom == .pad ? 80 : 20)
                    .background(Color(.systemGroupedBackground).ignoresSafeArea())
                
                List {
                    ForEach(locations.sorted { lhs, rhs in
                        if favorites.contains(lhs) != favorites.contains(rhs) {
                            return favorites.contains(lhs)
                        } else {
                            return lhs < rhs
                        }
                    }, id: \.self) { location in
                        HStack {
                            Text(location)
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20))
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .onTapGesture {
                                    Task {
                                        await selectLocation(city: location)
                                    }
                                    sharedText.text = location
                                    DispatchQueue.main.async {
                                        selection = 1 // Switch to WeatherView
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .swipeActions(allowsFullSwipe: false) {
                                    Button(role: .destructive, action: {
                                        if let draggingIndexSet = draggingIndexSet, draggingIndexSet.contains(locations.firstIndex(of: location)!) {
                                            // ignore deleting when the location is being dragged
                                        } else {
                                            removeLocation(location: location)
                                        }
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                                   
                            Button(action: {
                                toggleFavorite(location: location)
                            }) {
                                Image(systemName: favorites.contains(location) ? "star.fill" : "star")
                                    .foregroundColor(favorites.contains(location) ? .yellow : .gray)
                            }
                        }
                        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 30 : 10)
                        
                        Divider()
                    }
                    .onDelete(perform: removeLocations)
                }
                .listStyle(PlainListStyle())
                
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
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
            if let savedLocations = UserDefaults.standard.stringArray(forKey: "savedLocations") {
                locations = savedLocations
                // load favorites from UserDefaults
                if let savedFavorites = UserDefaults.standard.stringArray(forKey: "savedFavorites") {
                    favorites = Set(savedFavorites)
                }
            }
            }
                .navigationBarItems(trailing: EditButton())
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    
        func toggleFavorite(location: String) {
            if favorites.contains(location) {
                favorites.remove(location)
            } else {
                favorites.insert(location)
            }
            saveFavorites()
        }
    
        func saveLocations() {
            UserDefaults.standard.set(locations, forKey: "savedLocations")
        }

        func saveFavorites() {
            UserDefaults.standard.set(Array(favorites), forKey: "savedFavorites")
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
            
            if !trimmedLocation.isEmpty {
                Task {
                    await search(city: trimmedLocation)
                    if !showAlert {
                        locations.append(trimmedLocation)
                        saveLocations()
                    }
                    locationName = ""
                }
            }
        }
        //hide keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //clear text area
        locationName = ""
        isFocused = false
    }
    
    func removeLocations(at offsets: IndexSet) {
        let locationsToRemove = Array(Set(offsets.map { locations[$0] }).intersection(favorites))
        favorites.subtract(locationsToRemove)
        locations.remove(atOffsets: offsets)
        saveLocations()
    }
    
    func removeLocation(location: String) {
        if let index = locations.firstIndex(of: location) {
            withAnimation {
                if favorites.contains(location) {
                    favorites.remove(location)
                }
                locations.remove(at: index)
                saveLocations()
            }
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
        let replaced = (city as NSString).replacingOccurrences(of: " ", with: "+")
        locationManager.isLoading = true
        do {
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }),
               let windowScene = window.windowScene {
                try await locationManager.requestLocationByCity(city: replaced, presentingViewController: (windowScene.windows.first?.rootViewController)!)
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
