import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    private let mapBackButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "MapBack"), for: .normal)
        return button
    }()
    
    private let routeWalkthroughView: RouteWalkthroughView = {
        let view = RouteWalkthroughView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupMapView()
        setupLocationManager()
        setupMapBackButton()
        setupRouteWalkthroughView()
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 393)
        ])
        
        mapView.delegate = self
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupMapBackButton() {
        view.addSubview(mapBackButton)
        
        NSLayoutConstraint.activate([
            mapBackButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 67),
            mapBackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mapBackButton.widthAnchor.constraint(equalToConstant: 46),
            mapBackButton.heightAnchor.constraint(equalToConstant: 46)
        ])
        
        mapBackButton.addTarget(self, action: #selector(mapBackButtonTapped), for: .touchUpInside)
    }

    @objc private func mapBackButtonTapped() {
        // 아직 구현되지 않은 전 페이지로 이동하는 로직
        print("Map back button tapped")
    }
    
    private func setupRouteWalkthroughView() {
        view.addSubview(routeWalkthroughView)
        
        NSLayoutConstraint.activate([
            routeWalkthroughView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 27),
            routeWalkthroughView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routeWalkthroughView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routeWalkthroughView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let startCoordinate = location.coordinate
        let destinationCoordinate = CLLocationCoordinate2D(latitude: 36.1029, longitude: 129.3884) // 한동대학교 좌표
        
        showRoute(from: startCoordinate, to: destinationCoordinate)
        
        locationManager.stopUpdatingLocation()
    }
    
    func showRoute(from start: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
            self.adjustMapViewToFitRoute(route)
            
            self.addAnnotation(coordinate: start, title: "Start", imageName: "Start")
            self.addAnnotation(coordinate: destination, title: "Finish", imageName: "Finish")
        }
    }
    
    func adjustMapViewToFitRoute(_ route: MKRoute) {
        let rect = route.polyline.boundingMapRect
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mapView.setVisibleMapRect(rect, edgePadding: insets, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func addAnnotation(coordinate: CLLocationCoordinate2D, title: String, imageName: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "CustomPin"
        var view: MKAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        if annotation.title == "Start" {
            view.image = UIImage(named: "Start")
        } else if annotation.title == "Finish" {
            view.image = UIImage(named: "Finish")
        }
        
        view.canShowCallout = true
        return view
    }
}
