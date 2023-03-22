import SwiftUI

struct Location: Codable, Identifiable {
    let id: Int
    let name: String
}

struct View2: View {
    @State var locations = [Location]()
    @State var cityName = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter city name", text: $cityName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    addLocation()
                }
            }.padding()
            NavigationView {
                List {
                    ForEach(locations) { location in
                        Text(location.name)
                            .onTapGesture {
                                print(location.id)
                            }
                    }
                    .onDelete(perform: delete)
                }
                .navigationTitle("Locations")
                .navigationBarItems(trailing: EditButton())
            }
            /*List {
                ForEach(locations) { location in
                    Text(location.name)
                        .onTapGesture {
                            print(location.id)
                        }
                }
                .onDelete(perform: delete)
            }*/
        }
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=New%20York&appid=f1713ff8f3edf7b7afd6a48d1bd6c659") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(Location.self, from: data)
                        DispatchQueue.main.async {
                            locations.append(result)
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    func addLocation() {
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=f1713ff8f3edf7b7afd6a48d1bd6c659") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(Location.self, from: data)
                        DispatchQueue.main.async {
                            if !locations.contains(where: { $0.id == result.id }) {
                                locations.append(result)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    func delete(at offsets: IndexSet) {
            locations.remove(atOffsets: offsets)
        }
}




struct View2_Previews: PreviewProvider {
    static var previews: some View {
        View2()
    }
}
