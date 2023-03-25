import SwiftUI
import UIKit

struct FavouriteView: View {
    @State private var locationName = ""
    @StateObject private var favouriteLocationManager = FavouriteLocationManager()
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject var sharedText: SharedText
    @FocusState private var isFocused: Bool
    @Binding var selection: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Locations")
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 40))
                .fontWeight(.bold)
                .padding(UIDevice.current.userInterfaceIdiom == .pad ? 80 : 20)
            
            
            List {
                ForEach(favouriteLocationManager.locations) { location in
                    
                    Text(location.name)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20))
                        .fontWeight(.medium)
                        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 30 : 10)
                        .foregroundColor(.primary)
                        .onTapGesture {
                            sharedText.text = location.name
                            Task { await selectLocation(city: location.name) }
                            selection = 1 // Switch to WeatherView
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
                    let replaced = (locationName as NSString).replacingOccurrences(of: " ", with: "+")
                    let correct = replaced.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    favouriteLocationManager.addLocation(correct)
                    locationName = ""
                    isFocused = false
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
        .navigationBarItems(trailing: EditButton())
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
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

/*struct FavouriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteView(selection: selection)
    }
}*/
