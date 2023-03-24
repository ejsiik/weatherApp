import SwiftUI

struct FavouriteView: View {
    @State private var locationName = ""
    @StateObject private var favouriteLocationManager = FavouriteLocationManager()
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var sharedText: SharedText
    

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
                Button("Add") {
                    favouriteLocationManager.addLocation(locationName)
                    locationName = ""
                }
            }.padding()
        }
        .navigationBarItems(trailing: EditButton())
    }

    func selectLocation(city: String) async{
        do {
            try await locationManager.requestLocationByCity(city: city)
            sharedText.text = city
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
