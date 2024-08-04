import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    private let startCoordinate = CLLocationCoordinate2D(latitude: 35.87842746047693, longitude: 128.63362823950925)
    private let destinationCoordinate = CLLocationCoordinate2D(latitude: 35.88146982, longitude: 128.54040308)
    private var firstStationCoordinate: CLLocationCoordinate2D?
    private var busNumber: String?
    
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
        
        // 초기 지도 설정 및 시작/도착 마커 추가
        setInitialMapRegion()
        addAnnotation(coordinate: startCoordinate, title: "Start")
        addAnnotation(coordinate: destinationCoordinate, title: "Finish")
        
        // 초기 경로 표시
        showInitialRoute()
        routeWalkthroughView.setContentVisible(false)
        
        fetchBusStationInfo()
    }

    private func setInitialMapRegion() {
        let region = regionThatFitsTwoCoordinates(startCoordinate, destinationCoordinate)
        mapView.setRegion(region, animated: false)
    }

    private func regionThatFitsTwoCoordinates(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> MKCoordinateRegion {
        let points = [coord1, coord2].map { MKMapPoint($0) }
        let rect = points.reduce(MKMapRect.null) { $0.union(MKMapRect(origin: $1, size: MKMapSize(width: 0, height: 0))) }
        
        let center = CLLocationCoordinate2D(
            latitude: (coord1.latitude + coord2.latitude) / 2,
            longitude: (coord1.longitude + coord2.longitude) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: abs(coord1.latitude - coord2.latitude) * 1.3,
            longitudeDelta: abs(coord1.longitude - coord2.longitude) * 1.3
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private func showInitialRoute() {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first else { return }
            let initialPolyline = route.polyline
            initialPolyline.title = "InitialRoute"
            self.mapView.addOverlay(initialPolyline, level: .aboveRoads)
        }
    }
    
    private func addAnnotation(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    

    private func fetchNearbyBusStations() {
        NetworkManager.shared.getNearbyBusStations(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude) { [weak self] stations in
            guard let self = self, let firstStation = stations?.first else { return }
            
            DispatchQueue.main.async {
                self.routeWalkthroughView.updateBusStopName(firstStation.stationName)
                self.routeWalkthroughView.setContentVisible(true)
            }
        }
    }
    
    private func fetchBusStationInfo() {
        NetworkManager.shared.getNearbyBusStations(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude) { [weak self] stations in
            guard let self = self, let firstStation = stations?.first else { return }
            
            DispatchQueue.main.async {
                self.routeWalkthroughView.updateBusStopName(firstStation.stationName)
                self.routeWalkthroughView.setContentVisible(true)
            }
            
            self.getRouteAndStationXY(forStation: firstStation.stationId, destLatitude: self.destinationCoordinate.latitude, destLongitude: self.destinationCoordinate.longitude)
        }
    }

    private func getRouteAndStationXY(forStation stationId: String, destLatitude: Double, destLongitude: Double) {
        NetworkManager.shared.getRouteNumbers(forStation: stationId, destLatitude: destLatitude, destLongitude: destLongitude) { [weak self] routeNumbers in
            guard let self = self, let firstRouteId = routeNumbers?.first else { return }
            
            NetworkManager.shared.getStationXY(stationId: stationId, routeId: firstRouteId) { stationXY in
                guard let stationXY = stationXY else { return }
                
                self.firstStationCoordinate = CLLocationCoordinate2D(latitude: stationXY.latitude, longitude: stationXY.longitude)
                
                NetworkManager.shared.getBusNumber(routeId: firstRouteId) { busNum in
                    DispatchQueue.main.async {
                        if let busNum = busNum {
                            self.busNumber = busNum
                            self.routeWalkthroughView.updateBusNumber(busNum)
                        }
                        print("First station coordinates: \(self.firstStationCoordinate!)")
                        self.showCompleteRoute()
                    }
                }
            }
        }
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
            routeWalkthroughView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            routeWalkthroughView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routeWalkthroughView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routeWalkthroughView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        routeWalkthroughView.setContentVisible(false)
    }
    
    func adjustMapViewToFitRoute(_ route: MKRoute) {
        let rect = route.polyline.boundingMapRect
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mapView.setVisibleMapRect(rect, edgePadding: insets, animated: false)
    }
    
    private func showCompleteRoute() {
        guard let firstStationCoordinate = firstStationCoordinate else {
            print("First station coordinate is not available")
            return
        }

        mapView.removeOverlays(mapView.overlays)
        
        let walkRequest = MKDirections.Request()
        walkRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        walkRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: firstStationCoordinate))
        walkRequest.transportType = .walking

        let walkDirections = MKDirections(request: walkRequest)
        walkDirections.calculate { [weak self] response, error in
            guard let self = self, let walkRoute = response?.routes.first else { return }
            let walkPolyline = walkRoute.polyline
            walkPolyline.title = "WalkRoute"
            self.mapView.addOverlay(walkPolyline, level: .aboveRoads)

            let firstWalkTime = self.calculateWheelchairTime(distance: walkRoute.distance)

            NetworkManager.shared.getBusRoute(routeNum: "DGB4050001000", startLati: self.startCoordinate.latitude, startLong: self.startCoordinate.longitude, destLatitude: self.destinationCoordinate.latitude, destLongitude: self.destinationCoordinate.longitude) { [weak self] stations in
                guard let self = self, let stations = stations else { return }
                
                let lastStation = stations.min { station1, station2 in
                    let coord1 = CLLocationCoordinate2D(latitude: station1.latitude, longitude: station1.longitude)
                    let coord2 = CLLocationCoordinate2D(latitude: station2.latitude, longitude: station2.longitude)
                    return self.destinationCoordinate.distance(to: coord1) < self.destinationCoordinate.distance(to: coord2)
                }
                
                guard let lastStationCoordinate = lastStation.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }) else { return }
                
                let busRoute = stations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                let busPolyline = MKPolyline(coordinates: busRoute, count: busRoute.count)
                busPolyline.title = "BusRoute"
                self.mapView.addOverlay(busPolyline, level: .aboveRoads)
                
                let busDistance = busRoute.reduce(0.0) { (result, coordinate) in
                    if let lastCoordinate = busRoute.last {
                        return result + coordinate.distance(to: lastCoordinate)
                    }
                    return result
                }
                let busTime = self.calculateBusTime(distance: busDistance)

                let finalWalkRequest = MKDirections.Request()
                finalWalkRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: lastStationCoordinate))
                finalWalkRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.destinationCoordinate))
                finalWalkRequest.transportType = .walking
                
                let finalWalkDirections = MKDirections(request: finalWalkRequest)
                finalWalkDirections.calculate { response, error in
                    guard let finalWalkRoute = response?.routes.first else { return }
                    let finalWalkPolyline = finalWalkRoute.polyline
                    finalWalkPolyline.title = "FinalWalkRoute"
                    self.mapView.addOverlay(finalWalkPolyline, level: .aboveRoads)
                    
                    let finalWalkTime = self.calculateWheelchairTime(distance: finalWalkRoute.distance)
                    
                    let totalTime = firstWalkTime + busTime + finalWalkTime
                    let totalWheelchairTime = firstWalkTime + finalWalkTime
                    
                    DispatchQueue.main.async {
                        self.routeWalkthroughView.setupRouteInfo(
                            totalTime: totalTime,
                            wheelWalkTime: totalWheelchairTime,
                            firstWalkTime: firstWalkTime,
                            busTime: busTime,
                            finalWalkTime: finalWalkTime,
                            busNumber: self.busNumber ?? ""
                        )
                    }

                    let rect = walkRoute.polyline.boundingMapRect
                        .union(busPolyline.boundingMapRect)
                        .union(finalWalkRoute.polyline.boundingMapRect)
                    let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
                    self.mapView.setVisibleMapRect(rect, edgePadding: insets, animated: true)

                    self.addAnnotation(coordinate: self.destinationCoordinate, title: "Finish")
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            switch polyline.title {
            case "WalkRoute", "FinalWalkRoute":
                renderer.strokeColor = .gray
                renderer.lineDashPattern = [4, 4]
                renderer.lineWidth = 3
            case "BusRoute":
                renderer.strokeColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
                renderer.lineWidth = 4
            case "InitialRoute":
                renderer.strokeColor = UIColor.lightGray
                renderer.lineWidth = 3
            default:
                renderer.strokeColor = UIColor.black
                renderer.lineWidth = 3
            }
            return renderer
        }
        return MKOverlayRenderer()
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
         } else {
             // Bus Stop 또는 기타 마커의 경우 기본 핀 이미지 사용
             view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
         }
         
         view.canShowCallout = true
         return view
     }
    
    func calculateWheelchairTime(distance: CLLocationDistance) -> Int {
        // 휠체어 평균 속도를 시간당 2km로 가정
        let wheelchairSpeedKmPerHour = 2.0
        let timeInHours = distance / (wheelchairSpeedKmPerHour * 1000)
        return Int(ceil(timeInHours * 60))
    }

    func calculateBusTime(distance: CLLocationDistance) -> Int {
        // 버스 평균 속도를 시간당 30km로 가정
        let busSpeedKmPerHour = 30.0
        let timeInHours = distance / (busSpeedKmPerHour * 1000)
        return Int(ceil(timeInHours * 60))
    }
 }

extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return from.distance(from: to)
    }
}

