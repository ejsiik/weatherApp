import SwiftUI
import UIKit

struct FavouriteView: View {
    @State private var locationName = ""
    @StateObject private var favouriteLocationManager = FavouriteLocationManager()
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject var sharedText: SharedText
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            List {
                ForEach(favouriteLocationManager.locations) { location in
                    Text(location.name).onTapGesture {
                        Task { await selectLocation(city: location.name) }
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
            HStack {
                TextField("Enter city name", text: $locationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isFocused)
                Button("Add") {
                    let replaced = (locationName as NSString).replacingOccurrences(of: " ", with: "+")
                    let correct = replaced.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    favouriteLocationManager.addLocation(correct)
                    locationName = ""
                    isFocused = false
                }
            }.padding()
        }
        .navigationBarItems(trailing: EditButton())
    }

    func selectLocation(city: String) async{
        do {
            //try await locationManager.requestLocationByCity(city: city)
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let hostingController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                try await locationManager.requestLocationByCity(city: city, presentingViewController: hostingController)
            }
        } catch {
            print("Error \(error)" )
        }
    }
    
    func removeLocation(location: Location) {
        if let index = favouriteLocationManager.locations.firstIndex(where: { $0.id == location.id }) {
            favouriteLocationManager.locations.remove(at: index)
            favouriteLocationManager.saveLocations()
        }
    }

    func removeLocations(at offsets: IndexSet) {
        favouriteLocationManager.locations.remove(atOffsets: offsets)
        favouriteLocationManager.saveLocations()
    }
}

struct FavouriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteView()
    }
}
