//
//  ContentView.swift
//  Auto Map
//
//  Created by Alon Yakobichvili on 08.07.21.
//

import SwiftUI
import MapKit
import CoreLocation


extension View {
    func toAnyView() -> AnyView {
        return AnyView(self)
    }
}

struct ContentView: View {
    
    @StateObject var mapData = MapViewModel()
    @State var locationManager = CLLocationManager()
    
    var searchBar: AnyView {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search", text: $mapData.searchTxt)
                    .modifier(TextFieldClearButton(text: $mapData.searchTxt))
                    .colorScheme(.light)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .cornerRadius(10)
            .background(Color.white)
        }
        .padding(.horizontal, 30)
        .toAnyView()
    }
    
    
    var focusLocationButton: AnyView {
        Button(action: mapData.focusLocation) {
            Image(systemName: "location.fill")
                .font(.title2)
                .padding(10)
                .background(Color.primary)
                .clipShape(Circle())
        }.toAnyView()
    }
    
    var updateMapType: AnyView {
        Button(action: mapData.updateMapType) {
            Image(systemName: mapData.mapType == .standard ? "network" : "map")
                .font(.title2)
                .padding(10)
                .background(Color.primary)
                .clipShape(Circle())
        }.toAnyView()
    }
    
    var resultsView: AnyView {
        ScrollView {
            VStack {
                ForEach(mapData.places) { place in
                    Text(place.placemark.name ?? "")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .onTapGesture {
                            mapData.selectPlace(place: place)
                        }
                    Divider()
                }
            }
            .padding(.top)
        }
        .background(Color.white)
        .toAnyView()
    }
    
    var body: some View {
        ZStack {
            MapView()
                .environmentObject(mapData)
                .ignoresSafeArea(.all, edges: .all)
            // end Z stack
            VStack(alignment: .leading) {
                searchBar
                Spacer()
                if !mapData.places.isEmpty && mapData.searchTxt != "" {
                    resultsView
                    Spacer()
                    VStack {
                        focusLocationButton
                        updateMapType
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                }
            }
            .cornerRadius(8)
            .background(Color.black)
        }
        .onAppear {
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
        }
        .alert(isPresented: $mapData.permissionDenied) {
            Alert(title: Text("Permission Denied"),
                  message: Text("Please Enable Permission In App Settings"),
                  dismissButton: .default(Text("Go to Settings"),action: {
                    // Redirecting User to Settings
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                  }))
        }
        .onChange(of: mapData.searchTxt) { (value) in
            // Searching Places
            // You can use your own delay time to avoid Continuos Search Request
            let delay = 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if value == mapData.searchTxt {
                    // Search
                    self.mapData.searchQuery()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

struct MapView: UIViewRepresentable {
    @EnvironmentObject var mapData: MapViewModel
    
    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let view = mapData.mapView
        
        view.showsUserLocation = true
        view.delegate = context.coordinator
        
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        //
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Custom Pins
            
            // Excluding Used Blue Circle
            if annotation.isKind(of: MKUserLocation.self) {
                return nil
            } else {
                let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PIN_VIEW")
                pinAnnotation.tintColor = .red
                pinAnnotation.animatesDrop = true
                pinAnnotation.canShowCallout = true
                
                return pinAnnotation
            }
        }
    }
}

struct Place: Identifiable {
    var id = UUID().uuidString
    var placemark: MKPlacemark
}

struct Address: Identifiable {
    var id = UUID().uuidString
    var adressString: String
    var coordinates: CLLocationCoordinate2D
}

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var mapView = MKMapView()
    
    // Region
    @Published var region: MKCoordinateRegion!
    // Based on Location it will set up
    
    // Alert
    @Published var permissionDenied = false
    
    // Map Type
    @Published var mapType: MKMapType = .standard
    
    // SearchText
    @Published var searchTxt = ""
    
    // Searched Places
    @Published var places: [Place] = []
    
    @Published var addresses: [Address] = []
    
    func coordinates(forAddress address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                return
            }
            
            if let addresses = placemarks?.compactMap({ (place) -> Address? in
                return Address(adressString: address,
                               coordinates: place.location!.coordinate)
            }) {
                self.addresses = addresses
            }
        }
    }
    
    // Updating Map Type
    func updateMapType() {
        
        if mapType == .standard {
            mapType = .hybrid
            mapView.mapType = mapType
        } else {
            mapType = .standard
            mapView.mapType = mapType
        }
    }
    
    // Focus Location
    func focusLocation() {
        guard let _ = region else { return }
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    // Search Places
    func searchQuery() {
        
        places.removeAll()
        addresses.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTxt
        
        coordinates(forAddress: searchTxt)
        // Fetch
        MKLocalSearch(request: request).start { (response, _) in
            guard let result = response else { return }
            
            self.places = result.mapItems.compactMap({ (item) -> Place? in
                return Place(placemark: item.placemark)
            })
            self.places = self.places.sorted { $0.placemark.name! < $1.placemark.name! }
        }
    }
    
    // Pick Search Result
    func selectPlace(place: Place) {
        // Showing Pin on Map
        self.searchTxt = ""
        
        guard let coordinate = place.placemark.location?.coordinate else { return }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.placemark.name ?? "No Name"
        
        // Removing All Old Ones
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.addAnnotation(pointAnnotation)
        
        // Moving Map To That Location
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200 )
        
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Checking Permissions
        switch manager.authorizationStatus {
        case .denied:
            // Alert
            permissionDenied.toggle()
        case .notDetermined:
            // Requesting
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // If Permission Given
            manager.requestLocation()
        default:
            ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Error
        print(error.localizedDescription)
    }
    
    // Getting User Region
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        // Updating Map
        self.mapView.setRegion(self.region, animated: true)
        
        // Smooth Animations
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
}

struct TextFieldClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            
            if !text.isEmpty {
                Button(
                    action: { self.text = "" },
                    label: {
                        Image(systemName: "delete.left")
                            .foregroundColor(Color(UIColor.opaqueSeparator))
                    }
                )
            }
        }
    }
}
