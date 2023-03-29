import SwiftUI
import MapKit
import CoreLocation
import Network

extension String {
    func spaces(using chRcterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: chRcterSet)
    }
}

struct MapLocationView: View {
    @State private var userLocation = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 54.5260, longitude: 15.2551),
            span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50))
    @State private var showAlert = false
    @State private var selectedCity = ""
    @StateObject private var locationManager = LocationMapManager()
    @EnvironmentObject var sharedText: SharedText
    @Binding var selection: Int
    @EnvironmentObject var locationMapManager: LocationManager
    @State private var showInternetAlert = false
    
    
    var body: some View {
        VStack {
            if(showInternetAlert == false) {
                MapView(coordinateRegion: $userLocation, onTap: onTapGesture)
                    .edgesIgnoringSafeArea(.all)
                Button(action: {
                    locationManager.requestLocation()
                    if let location = locationManager.lastLocation {
                        userLocation = MKCoordinateRegion(center: location.coordinate, span: userLocation.span)
                    }
                }, label: {
                    Text("Locate me")
                })
            } else {
                ZStack {
                    Text("Error while loading map")
                }
                .background(Color.black)
            }
        }
        .onAppear{
            checkInternetConnection()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Get Weather"),
                message: Text("Are you sure you want to get weather for \(selectedCity)?"),
                primaryButton: .default(Text("Yes"), action: {
                    Task {
                        await selectLocation(city: selectedCity)
                    }
                    sharedText.text = selectedCity
                    DispatchQueue.main.async {
                        selection = 1 // Switch to WeatherView
                    }
                }),
                secondaryButton: .cancel(Text("No"))
            )
        }
    }
    
    func selectLocation(city: String) async {
        sharedText.text = city
        
        do {
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let hostingController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                
                try await locationMapManager.requestLocationByCity(city: city, presentingViewController: hostingController)
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
    
    func search(city: String) async {
        locationMapManager.isLoading = true
        do {
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }),
               let windowScene = window.windowScene {
                try await locationMapManager.requestLocationByCity(city: city, presentingViewController: (windowScene.windows.first?.rootViewController)!)
            }
        } catch {
            await MainActor.run {
                print("alert1")
            }
        }
        locationMapManager.isLoading = false
    }

    private func onTapGesture(coordinate: CLLocationCoordinate2D) {
          let geoCoder = CLGeocoder()
          let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
          
          geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
              if let error = error {
                  print("Error: \(error.localizedDescription)")
              } else {
                  if let placemark = placemarks?.first,
                     let city = placemark.locality {
                      selectedCity = city
                      showAlert = true
                  }
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
  }

struct MapView: UIViewRepresentable {
    @Binding var coordinateRegion: MKCoordinateRegion
    var onTap: ((CLLocationCoordinate2D) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(recognizer:)))
        mapView.addGestureRecognizer(tapRecognizer)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(coordinateRegion, animated: true)
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var control: MapView
        
        init(_ control: MapView) {
            self.control = control
        }
        
        @objc func handleTap(recognizer: UITapGestureRecognizer) {
            let mapView = recognizer.view as! MKMapView
            let tapPoint = recognizer.location(in: mapView)
            let tapCoordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            
            control.onTap?(tapCoordinate)
        }
    }
}

final class LocationMapManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
