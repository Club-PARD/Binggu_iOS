import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    private let startCoordinate = CLLocationCoordinate2D(latitude: 35.88934560701709, longitude: 128.6159348487854)
    private let destinationCoordinate = CLLocationCoordinate2D(latitude: 35.8438086, longitude: 128.5670053)
    private let preferredStationId = "DGB7011010100"
    private let preferredRouteId = "DGB3000503000"
    private var firstStationCoordinate: CLLocationCoordinate2D?
    private var busNumber: String?
    private var currentLocationButton: UIButton!
    private var shouldUpdateUserLocation = false
    private var userTrackingButton: MKUserTrackingButton!
    private var stationId: String?
    private var routeId: String?
    private var destinationName = "대구가톨릭대학병원"
    
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
        setupCurrentLocationButton()
    }

    @objc private func currentLocationButtonTapped() {
        shouldUpdateUserLocation = true
        locationManager.requestLocation()
    }
    
    private func setupCurrentLocationButton() {
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.backgroundColor = .clear // 배경색을 투명하게 설정
        
        // 버튼을 감싸는 컨테이너 뷰 생성
        let containerView = UIView()
        containerView.backgroundColor = UIColor(white: 1, alpha: 0.8)
        containerView.layer.cornerRadius = 5
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.masksToBounds = true // 내용이 테두리를 넘지 않도록 설정
        
        containerView.addSubview(userTrackingButton)
        mapView.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
            containerView.widthAnchor.constraint(equalToConstant: 40),
            containerView.heightAnchor.constraint(equalToConstant: 40),
            
            userTrackingButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            userTrackingButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            userTrackingButton.widthAnchor.constraint(equalToConstant: 36), // 버튼 크기를 약간 줄임
            userTrackingButton.heightAnchor.constraint(equalToConstant: 36)
        ])
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
    
    private func fetchBusStationInfo() {
        NetworkManager.shared.getNearbyBusStations(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude) { [weak self] stations in
            guard let self = self, let stations = stations else {
                print("No stations found")
                return
            }
            
            let preferredStation = stations.first { $0.stationId == self.preferredStationId }
            let selectedStation = preferredStation ?? stations[4]
            
            self.stationId = selectedStation.stationId  // 여기서 stationId 설정
            
            DispatchQueue.main.async {
                self.routeWalkthroughView.updateBusStopName(selectedStation.stationName)
                self.routeWalkthroughView.setContentVisible(true)
            }
            
            self.getRouteAndStationXY(forStation: selectedStation.stationId, destLatitude: self.destinationCoordinate.latitude, destLongitude: self.destinationCoordinate.longitude)
        }
    }
    
    private func getRouteAndStationXY(forStation stationId: String, destLatitude: Double, destLongitude: Double) {
        NetworkManager.shared.getRouteNumbers(forStation: stationId, destLatitude: destLatitude, destLongitude: destLongitude) { [weak self] routeNumbers in
            guard let self = self, let routeNumbers = routeNumbers else { return }
            
            let selectedRouteId = routeNumbers.first { $0 == self.preferredRouteId } ?? routeNumbers.first
            
            guard let routeId = selectedRouteId else { return }
            
            self.routeId = routeId
            
            NetworkManager.shared.getStationXY(stationId: stationId, routeId: routeId) { stationXY in
                guard let stationXY = stationXY else { return }
                
                self.firstStationCoordinate = CLLocationCoordinate2D(latitude: stationXY.latitude, longitude: stationXY.longitude)
                
                NetworkManager.shared.getBusNumber(routeId: routeId) { busNum in
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
        mapView.showsUserLocation = true
        
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
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard shouldUpdateUserLocation, let location = locations.last else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        shouldUpdateUserLocation = false
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
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
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupRouteWalkthroughView() {
        view.addSubview(routeWalkthroughView)
        
        NSLayoutConstraint.activate([
            routeWalkthroughView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            routeWalkthroughView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            routeWalkthroughView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            routeWalkthroughView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        routeWalkthroughView.updateDestination(destinationName)
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
        
        // 출발지에서 50m 떨어진 지점 계산
        let closestStartPoint = getClosestPointToStart(from: startCoordinate)
        
        // Add annotation for the first bus stop
        addAnnotation(coordinate: firstStationCoordinate, title: "BusStop")

        let walkRequest = MKDirections.Request()
        walkRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: closestStartPoint))
        walkRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: firstStationCoordinate))
        walkRequest.transportType = .walking

        let walkDirections = MKDirections(request: walkRequest)
        walkDirections.calculate { [weak self] response, error in
            guard let self = self, let walkRoute = response?.routes.first else { return }
            let walkPolyline = walkRoute.polyline
            let firstWalkDistance = walkRoute.distance
            walkPolyline.title = "WalkRoute"
            self.mapView.addOverlay(walkPolyline, level: .aboveRoads)

            let firstWalkTime = self.calculateWheelchairTime(distance: walkRoute.distance)

            NetworkManager.shared.getBusRoute(routeNum: self.preferredRouteId, startLati: self.startCoordinate.latitude, startLong: self.startCoordinate.longitude, destLatitude: self.destinationCoordinate.latitude, destLongitude: self.destinationCoordinate.longitude) { [weak self] stations in
                guard let self = self, let stations = stations else { return }
                
                let lastStation = stations.min { station1, station2 in
                    let coord1 = CLLocationCoordinate2D(latitude: station1.latitude, longitude: station1.longitude)
                    let coord2 = CLLocationCoordinate2D(latitude: station2.latitude, longitude: station2.longitude)
                    return self.destinationCoordinate.distance(to: coord1) < self.destinationCoordinate.distance(to: coord2)
                }
                
                guard let lastStationCoordinate = lastStation.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }) else { return }
                
                // Add annotation for the last bus stop
                self.addAnnotation(coordinate: lastStationCoordinate, title: "BusStop")
                
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

                // 최종 도보 경로 계산 부분 수정
                let finalWalkRequest = MKDirections.Request()
                finalWalkRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: lastStationCoordinate))
                finalWalkRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.destinationCoordinate))
                finalWalkRequest.transportType = .walking
                
                let finalWalkDirections = MKDirections(request: finalWalkRequest)
                finalWalkDirections.calculate { response, error in
                    guard let finalWalkRoute = response?.routes.first else { return }
                    let finalWalkPolyline = finalWalkRoute.polyline
                    let lastWalkDistance = finalWalkRoute.distance
                    finalWalkPolyline.title = "FinalWalkRoute"
                    self.mapView.addOverlay(finalWalkPolyline, level: .aboveRoads)
                    
                    let finalWalkTime = self.calculateWheelchairTime(distance: finalWalkRoute.distance)
                    
                    let totalTime = firstWalkTime + busTime + finalWalkTime
                    let totalWheelchairTime = firstWalkTime + finalWalkTime
                    
                    DispatchQueue.main.async {
                        self.routeWalkthroughView.updateWalkDistances(firstWalkDistance: firstWalkDistance, lastWalkDistance: lastWalkDistance)
                        self.routeWalkthroughView.setupRouteInfo(
                            totalTime: totalTime,
                            wheelWalkTime: totalWheelchairTime,
                            firstWalkTime: firstWalkTime,
                            busTime: busTime,
                            finalWalkTime: finalWalkTime,
                            busNumber: self.busNumber ?? "",
                            stationId: self.stationId ?? "",
                            routeId: self.routeId ?? ""
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
    
    // 출발지에서 가장 가까운 지점 계산
    private func getClosestPointToStart(from coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let angle: Double = 0.0
        let distance: Double = 50.0
        let earthRadius: Double = 6371000.0

        let newLatitude = coordinate.latitude + (distance / earthRadius) * (180 / .pi)
        let newLongitude = coordinate.longitude + (distance / earthRadius) * (180 / .pi) / cos(coordinate.latitude * .pi / 180)

        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }
    
    // 목적지와 가장 가까운 지점 계산
    private func getClosestPointToDestination(from coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // 기존 도착지에서 50m 떨어진 지점으로 설정
        let angle: Double = 0.0
        let distance: Double = 50.0
        let earthRadius: Double = 6371000.0

        let newLatitude = coordinate.latitude + (distance / earthRadius) * (180 / .pi)
        let newLongitude = coordinate.longitude + (distance / earthRadius) * (180 / .pi) / cos(coordinate.latitude * .pi / 180)

        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
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
        if annotation is MKUserLocation {
            return nil // 기본 파란색 점 사용
        }
        
        let identifier = "CustomPin"
        var view: MKAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        switch annotation.title {
        case "Start":
            view.image = UIImage(named: "Start")
        case "Finish":
            view.image = UIImage(named: "Finish")
        case "BusStop":
            view.image = UIImage(named: "BusStop")
        default:
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        view.canShowCallout = true
        return view
    }
    
    func calculateWheelchairTime(distance: CLLocationDistance) -> Int {
        let wheelchairSpeedKmPerHour = 2.0
        let timeInHours = distance / (wheelchairSpeedKmPerHour * 1000)
        return Int(ceil(timeInHours * 60))
    }

    func calculateBusTime(distance: CLLocationDistance) -> Int {
        let busSpeedKmPerHour = 140.0
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
