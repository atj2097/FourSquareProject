import UIKit
import MapKit
import CoreLocation

class LibraryViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var locationEntry: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    let initialLocation = CLLocation(latitude: 40.742054, longitude: -73.769417)
    let searchRadius: CLLocationDistance = 2000
    
    private var libraries = [LibraryWrapper]() {
        didSet {
            mapView.addAnnotations(libraries.filter{ $0.hasValidCoordinates})
        }
    }
    
    var searchString: String? = nil {
        didSet{
            mapView.addAnnotations(libraries.filter{ $0.hasValidCoordinates})
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        locationEntry.delegate = self
        mapView.userTrackingMode = .follow
        locationAuthorization()
        loadData()
       
    }
    
    func loadData() {
        libraries = LibraryWrapper.getLibraries(from: GetLocation.getData(name: "BklynLibraryInfo", type: "json"))
    }
    
    private func locationAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        default:
            locationManager.requestWhenInUseAuthorization()
            
        }
    }


}

extension LibraryViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("New location: \(locations)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorozation status changed to \(status.rawValue)")
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            //Call a function to get the current location
            
        default:
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
    
}

extension LibraryViewController: MKMapViewDelegate {
    
    
}

extension LibraryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        locationEntry.showsCancelButton = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        locationEntry.showsCancelButton = false
        locationEntry.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         //create activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        searchBar.resignFirstResponder()
        
        //search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            activityIndicator.stopAnimating()
            
            if response == nil {
                print(error)
            } else {
                //remove annotations
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                //get data
                let latitud = response?.boundingRegion.center.latitude
                let longitud = response?.boundingRegion.center.longitude
                
                let newAnnotation = MKPointAnnotation()
                newAnnotation.title = searchBar.text
                newAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitud!, longitude: longitud!)
                self.mapView.addAnnotation(newAnnotation)
                
                //to zoom in the annotation
                let coordinateRegion = MKCoordinateRegion.init(center: newAnnotation.coordinate, latitudinalMeters: self.searchRadius * 2.0, longitudinalMeters: self.searchRadius * 2.0)
                self.mapView.setRegion(coordinateRegion, animated: true)
            }
        }

    }
    
}
