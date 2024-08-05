import Foundation

struct BusStation: Codable {
    let stationId: String
    let stationName: String
    let routeNum: Int
}

struct RouteResponse: Codable {
    let routeNumList: [String]
}

struct StationXYResponse: Codable {
    let stationId: String
    let latitude: Double
    let longitude: Double
}

struct BusRouteStation: Codable {
    let latitude: Double
    let longitude: Double
    let nodeid: String
    let stationName: String
    let stationNum: Int
    let upDown: Int
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://ec2-3-34-193-237.ap-northeast-2.compute.amazonaws.com:8080"
    
    private init() {}
    
    func getNearbyBusStations(latitude: Double, longitude: Double, completion: @escaping ([BusStation]?) -> Void) {
        let url = URL(string: "\(baseURL)/bus/station")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["latitude": latitude, "longtitude": longitude]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("NetworkManager: Sending request to \(url)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("NetworkManager: Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("NetworkManager: Received response with status code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("NetworkManager: No data received")
                completion(nil)
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("NetworkManager: Received JSON: \(jsonResult)")
                }
                
                let stations = try JSONDecoder().decode([BusStation].self, from: data)
                print("NetworkManager: Successfully decoded \(stations.count) stations")
                completion(stations)
            } catch {
                print("NetworkManager: Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func getRouteNumbers(forStation stationId: String, destLatitude: Double, destLongitude: Double, completion: @escaping ([String]?) -> Void) {
        let url = URL(string: "\(baseURL)/bus/routeNum")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["stationId": stationId, "destLatitude": destLatitude, "destLongtitude": destLongitude]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RouteResponse.self, from: data)
                completion(response.routeNumList)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func getStationXY(stationId: String, routeId: String, completion: @escaping (StationXYResponse?) -> Void) {
        let url = URL(string: "\(baseURL)/bus/stationXY")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["stationId": stationId, "routeId": routeId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(StationXYResponse.self, from: data)
                completion(response)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func getBusRoute(routeNum: String, startLati: Double, startLong: Double, destLatitude: Double, destLongitude: Double, completion: @escaping ([BusRouteStation]?) -> Void) {
        let url = URL(string: "\(baseURL)/bus/route")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "routeNum": routeNum,
            "startLati": startLati,
            "startLong": startLong,
            "destLatitude": destLatitude,
            "destLongtitude": destLongitude
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let stations = try JSONDecoder().decode([BusRouteStation].self, from: data)
                completion(stations)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func getBusNumber(routeId: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "\(baseURL)/bus/busNum")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["routeId": routeId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let busNum = json["busNum"] as? String {
                    completion(busNum)
                } else {
                    completion(nil)
                }
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
