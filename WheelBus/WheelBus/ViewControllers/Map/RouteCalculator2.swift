import Foundation
import CoreLocation
import UIKit

class RouteCalculator2 {
    private let startCoordinate = CLLocationCoordinate2D(latitude: 35.8571043, longitude: 128.5483635)
    private let destinationCoordinate = CLLocationCoordinate2D(latitude: 35.8411705, longitude: 128.6815273)
    private let preferredStationId = "DGB7041024200"
    private let preferredRouteId = "DGB3000509000"
    
    var completionHandler: (() -> Void)?
    
    func calculateRoute() {
        print("RouteCalculator2: Starting route calculation")
        fetchBusStationInfo()
    }
    
    private func updateAppDelegate(_ update: @escaping (AppDelegate) -> Void) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                update(appDelegate)
                print("RouteCalculator: AppDelegate updated on main thread")
            } else {
                print("RouteCalculator: Failed to get AppDelegate")
            }
        }
    }
    
    private func fetchBusStationInfo() {
        print("RouteCalculator2: Fetching bus station info")
        NetworkManager.shared.getNearbyBusStations(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude) { [weak self] stations in
            guard let self = self else {
                print("RouteCalculator2: Self is nil in fetchBusStationInfo completion")
                return
            }
            
            if let stations = stations {
                print("RouteCalculator2: Received \(stations.count) stations")
                
                let preferredStation = stations.first { $0.stationId == self.preferredStationId }
                let selectedStation = preferredStation ?? stations.first
                
                if let selectedStation = selectedStation {
                    print("RouteCalculator2: Selected station - \(selectedStation.stationName)")
                    self.updateAppDelegate { $0.firstStationRoute2 = selectedStation.stationName }
                    self.getRouteAndStationXY(forStation: selectedStation.stationId, destLatitude: self.destinationCoordinate.latitude, destLongitude: self.destinationCoordinate.longitude)
                } else {
                    print("RouteCalculator2: No suitable station found")
                    self.completionHandler?()
                }
            } else {
                print("RouteCalculator2: Failed to get stations")
                self.completionHandler?()
            }
        }
    }
    
    private func getRouteAndStationXY(forStation stationId: String, destLatitude: Double, destLongitude: Double) {
        print("RouteCalculator2: Getting route and station XY for station \(stationId)")
        NetworkManager.shared.getRouteNumbers(forStation: stationId, destLatitude: destLatitude, destLongitude: destLongitude) { [weak self] routeNumbers in
            guard let self = self else {
                print("RouteCalculator2: Self is nil in getRouteNumbers completion")
                return
            }
            
            if let routeNumbers = routeNumbers {
                print("RouteCalculator2: Received \(routeNumbers.count) route numbers")
                
                let selectedRouteId = routeNumbers.first { $0 == self.preferredRouteId } ?? routeNumbers.first
                
                guard let routeId = selectedRouteId else {
                    print("RouteCalculator2: No valid route ID found")
                    self.completionHandler?()
                    return
                }
                
                print("RouteCalculator2: Selected route ID: \(routeId)")
                self.getStationXY(stationId: stationId, routeId: routeId)
            } else {
                print("RouteCalculator2: No route numbers found")
                self.completionHandler?()
            }
        }
    }
    
    private func getStationXY(stationId: String, routeId: String) {
        print("RouteCalculator2: Getting station XY for station \(stationId) and route \(routeId)")
        NetworkManager.shared.getStationXY(stationId: stationId, routeId: routeId) { [weak self] stationXY in
            guard let self = self else {
                print("RouteCalculator2: Self is nil in getStationXY completion")
                return
            }
            
            if let stationXY = stationXY {
                print("RouteCalculator2: Received station XY: (\(stationXY.latitude), \(stationXY.longitude))")
                let firstStationCoordinate = CLLocationCoordinate2D(latitude: stationXY.latitude, longitude: stationXY.longitude)
                self.getBusNumber(routeId: routeId, firstStationCoordinate: firstStationCoordinate)
            } else {
                print("RouteCalculator2: No station XY found")
                self.completionHandler?()
            }
        }
    }
    
    private func getBusNumber(routeId: String, firstStationCoordinate: CLLocationCoordinate2D) {
        print("RouteCalculator2: Getting bus number for route \(routeId)")
        NetworkManager.shared.getBusNumber(routeId: routeId) { [weak self] busNum in
            guard let self = self else {
                print("RouteCalculator2: Self is nil in getBusNumber completion")
                return
            }
            
            if let busNum = busNum {
                print("RouteCalculator2: Received bus number: \(busNum)")
                self.updateAppDelegate { $0.busNumRoute2 = busNum }
            } else {
                print("RouteCalculator2: No bus number received")
            }
            
            self.calculateTimes(firstStationCoordinate: firstStationCoordinate)
        }
    }
    
    private func calculateTimes(firstStationCoordinate: CLLocationCoordinate2D) {
        print("RouteCalculator2: Calculating times")
        let firstWalkDistance = self.startCoordinate.distance(to: firstStationCoordinate)
        let firstWalkTime = self.calculateWheelchairTime(distance: firstWalkDistance)
        
        print("RouteCalculator2: First walk distance: \(firstWalkDistance), time: \(firstWalkTime)")
        self.updateAppDelegate { $0.walkTime1Route2 = firstWalkTime }
        
        self.getBusRoute(firstStationCoordinate: firstStationCoordinate)
    }
    
    private func getBusRoute(firstStationCoordinate: CLLocationCoordinate2D) {
        print("RouteCalculator2: Getting bus route")
        NetworkManager.shared.getBusRoute(routeNum: self.preferredRouteId, startLati: self.startCoordinate.latitude, startLong: self.startCoordinate.longitude, destLatitude: self.destinationCoordinate.latitude, destLongitude: self.destinationCoordinate.longitude) { [weak self] stations in
            guard let self = self else {
                print("RouteCalculator2: Self is nil in getBusRoute completion")
                return
            }
            
            if let stations = stations {
                print("RouteCalculator2: Received \(stations.count) stations for bus route")
                self.processBusRoute(stations: stations, firstStationCoordinate: firstStationCoordinate)
            } else {
                print("RouteCalculator2: No bus route found")
                self.completionHandler?()
            }
        }
    }
    
    private func processBusRoute(stations: [BusRouteStation], firstStationCoordinate: CLLocationCoordinate2D) {
        print("RouteCalculator2: Processing bus route")
        let lastStation = stations.min { station1, station2 in
            let coord1 = CLLocationCoordinate2D(latitude: station1.latitude, longitude: station1.longitude)
            let coord2 = CLLocationCoordinate2D(latitude: station2.latitude, longitude: station2.longitude)
            return self.destinationCoordinate.distance(to: coord1) < self.destinationCoordinate.distance(to: coord2)
        }
        
        guard let lastStationCoordinate = lastStation.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }) else {
            print("RouteCalculator2: Could not determine last station")
            self.completionHandler?()
            return
        }
        
        print("RouteCalculator2: Last station coordinate: (\(lastStationCoordinate.latitude), \(lastStationCoordinate.longitude))")
        
        let busRoute = stations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        let busDistance = busRoute.reduce(0.0) { (result, coordinate) in
            if let lastCoordinate = busRoute.last {
                return result + coordinate.distance(to: lastCoordinate)
            }
            return result
        }
        let busTime = self.calculateBusTime(distance: busDistance)
        
        print("RouteCalculator2: Bus distance: \(busDistance), time: \(busTime)")
        
        let finalWalkDistance = lastStationCoordinate.distance(to: self.destinationCoordinate)
        let finalWalkTime = self.calculateWheelchairTime(distance: finalWalkDistance)
        
        print("RouteCalculator2: Final walk distance: \(finalWalkDistance), time: \(finalWalkTime)")
        
        self.updateAppDelegate {
            $0.busTimeRoute2 = busTime
            $0.finalStationRoute2 = lastStation?.stationName
            $0.walkTime2Route2 = finalWalkTime
        }
        
        print("RouteCalculator2: Calculation completed")
        DispatchQueue.main.async {
            self.completionHandler?()
        }
    }
    
    private func calculateWheelchairTime(distance: CLLocationDistance) -> Int {
        let wheelchairSpeedKmPerHour = 2.0
        let timeInHours = distance / (wheelchairSpeedKmPerHour * 1000)
        let timeInMinutes = Int(ceil(timeInHours * 60))
        print("RouteCalculator2: Calculated wheelchair time: \(timeInMinutes) minutes for distance: \(distance)")
        return timeInMinutes
    }
    
    private func calculateBusTime(distance: CLLocationDistance) -> Int {
        let busSpeedKmPerHour = 140.0
        let timeInHours = distance / (busSpeedKmPerHour * 1000)
        let timeInMinutes = Int(ceil(timeInHours * 60))
        print("RouteCalculator2: Calculated bus time: \(timeInMinutes) minutes for distance: \(distance)")
        return timeInMinutes
    }
}
