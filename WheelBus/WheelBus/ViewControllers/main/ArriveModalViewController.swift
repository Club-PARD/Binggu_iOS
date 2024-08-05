//
//  ArriveModalViewController.swift
//  WheelBus
//
//  Created by 유재혁 on 8/3/24.
//

import UIKit
import MapKit
import CoreLocation

protocol ArriveModalViewControllerDelegate: AnyObject {
    func arriveModalViewController(_ viewController: ArriveModalViewController, didSelectAddress address: String)
}

class ArriveModalViewController: UIViewController, UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    weak var delegate: ArriveModalViewControllerDelegate?
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    private let resultsTableView = UITableView()
    private var searchWorkItem: DispatchWorkItem?
    
    private let locationManager = CLLocationManager()   //내위치 찾기
    
    private lazy var myLocationButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "내위치"
        configuration.baseBackgroundColor = .white

        var titleAttributes = AttributeContainer()
           titleAttributes.font = UIFont.nanumSquareNeo(.bold, size: 14) // 원하는 폰트와 크기로 설정
           titleAttributes.foregroundColor = #colorLiteral(red: 0.3123708963, green: 0.567548573, blue: 1, alpha: 1)
           
        configuration.attributedTitle = AttributedString("내위치", attributes: titleAttributes)

        // 이미지 추가
        let image = UIImage(named: "gps")  // 원하는 이미지를 시스템 이미지로 설정
        configuration.image = image
        configuration.imagePadding = 1

        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(myLocationButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 17
        button.layer.borderColor = #colorLiteral(red: 0.3123708963, green: 0.567548573, blue: 1, alpha: 1)
        button.layer.borderWidth = 1
        
        return button
    }()
    
    let search: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "도착지 검색"
        label.font = UIFont.nanumSquareNeo(.bold, size: 24)
        label.textColor = .black
        return label
    }()
    
    var line: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(red: 0.929, green: 0.929, blue: 0.929, alpha: 1)
        return line
    }()
    
    
    var shortline: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1)
        line.layer.borderWidth = 5
        line.layer.cornerRadius = 3
        line.layer.borderColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1).cgColor
        return line
    }()
    
    //검색창
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "도착지 입력"
        searchBar.searchBarStyle = .minimal // 검색창의 형태 최대한 간소화
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 0, vertical: 0)   //돋보기와 텍스트 상자 간격 조절
        
        // 전체 SearchBar의 배경색을 하얀색으로 설정
        searchBar.backgroundColor = .white
        
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.translatesAutoresizingMaskIntoConstraints = false
            searchTextField.backgroundColor = .white  // TextField의 배경색도 하얀색으로 설정
            searchTextField.layer.cornerRadius = 10
            searchTextField.layer.borderWidth = 1
            searchTextField.layer.borderColor = UIColor(red: 0.908, green: 0.908, blue: 0.908, alpha: 1).cgColor
            searchTextField.clipsToBounds = true
            
            // 입력 텍스트의 폰트 변경
            searchTextField.font = UIFont.nanumSquareNeo(.bold, size: 16)
            
            // Placeholder 텍스트의 폰트와 색상 변경
            let placeholderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.nanumSquareNeo(.bold, size: 16),
                .foregroundColor: #colorLiteral(red: 0.7803922296, green: 0.7803922296, blue: 0.7803922296, alpha: 1)
            ]
            searchTextField.attributedPlaceholder = NSAttributedString(string: "도착지 입력", attributes: placeholderAttributes)
            
            // 배경 뷰 제거
            searchTextField.background = nil
            searchTextField.borderStyle = .none
            
            searchTextField.leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            let image = UIImage(systemName: "magnifyingglass")
            imageView.image = image
            imageView.tintColor = .gray
            
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20)) // 패딩 뷰 생성
            paddingView.addSubview(imageView)
            imageView.center = CGPoint(x: paddingView.frame.size.width - 13, y: paddingView.frame.size.height / 2)
            
            searchTextField.leftView = paddingView
        }
        
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupSearchCompleter()
        setupLocationManager()
        searchBar.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchWorkItem?.cancel()
    }
    
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.pointOfInterest, .address]
        
        // 한국의 대략적인 중심점과 범위 설정
        let center = CLLocationCoordinate2D(latitude: 35.907757, longitude: 127.766922)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: center, span: span)
        
        searchCompleter.region = region
    }
    
    private func setupLocationManager() {
       locationManager.delegate = self
       locationManager.desiredAccuracy = kCLLocationAccuracyBest
   }
    
    @objc private func myLocationButtonTapped() {
           locationManager.requestWhenInUseAuthorization()
           locationManager.requestLocation()
       }

    func setupUI() {
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.register(AddressTableViewCell.self, forCellReuseIdentifier: AddressTableViewCell.identifier)
        resultsTableView.isHidden = true
        
        // separatorInset을 사용하여 separator line의 길이를 조정 (셀 사이의 경계선)
        resultsTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        resultsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBar)
        view.addSubview(search)
        view.addSubview(line)
        view.addSubview(resultsTableView)
        view.addSubview(shortline)
        view.addSubview(myLocationButton)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: search.bottomAnchor, constant: 27),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            searchBar.heightAnchor.constraint(equalToConstant: 56),
            
            searchBar.searchTextField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            searchBar.searchTextField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            searchBar.searchTextField.topAnchor.constraint(equalTo: searchBar.topAnchor),
            searchBar.searchTextField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor),
            
            search.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            search.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            
            line.bottomAnchor.constraint(equalTo: resultsTableView.topAnchor),
            line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
            
            resultsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 53),
            resultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            resultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            resultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            
            shortline.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            shortline.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shortline.widthAnchor.constraint(equalToConstant: 78),
            shortline.heightAnchor.constraint(equalToConstant: 5),
            
            myLocationButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            myLocationButton.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            myLocationButton.widthAnchor.constraint(equalToConstant: 85),
            myLocationButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    // 빈화면 터치시 키보드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()  // 키보드 내리기
            return true
    }
    // MARK: - UISearchBarDelegate
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.isEmpty {
//            searchResults = []
//            resultsTableView.isHidden = true
//        } else {
//            searchCompleter.queryFragment = searchText
//            resultsTableView.isHidden = false
//        }
//        resultsTableView.reloadData()
//    }
//
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(with: searchText)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        searchWorkItem = workItem
    }

    private func performSearch(with searchText: String) {
        if searchText.isEmpty {
            searchResults = []
            resultsTableView.isHidden = true
            resultsTableView.reloadData()
            return
        }
        
        let components = searchText.components(separatedBy: " ").filter { !$0.isEmpty }
        if components.count > 1 {
            // 지역명과 장소명이 함께 입력된 경우
            let regionName = components[0]
            let placeName = components.dropFirst().joined(separator: " ")
            searchCompleter.queryFragment = "\(regionName) \(placeName)"
        } else {
            // 단일 검색어인 경우
            searchCompleter.queryFragment = searchText
        }
        
        resultsTableView.isHidden = false
        resultsTableView.reloadData()
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        resultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ArriveModalViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddressTableViewCell.identifier, for: indexPath) as? AddressTableViewCell else {
            return UITableViewCell()
        }
        
        let result = searchResults[indexPath.row]
        cell.configure(with: result)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        let fullAddress = "\(selectedResult.title), \(removeCountryAndPostalCode(from: selectedResult.subtitle))"
        delegate?.arriveModalViewController(self, didSelectAddress: fullAddress)
        dismiss(animated: true, completion: nil)
    }

    private func removeCountryAndPostalCode(from subtitle: String) -> String {
        var modifiedSubtitle = subtitle
        modifiedSubtitle = modifiedSubtitle.replacingOccurrences(of: "대한민국", with: "")
        if let range = modifiedSubtitle.range(of: ", \\d{5}", options: .regularExpression) {
            modifiedSubtitle = modifiedSubtitle.replacingCharacters(in: range, with: "")
        }
        if let range = modifiedSubtitle.range(of: "\\d{5}", options: .regularExpression) {
            modifiedSubtitle = modifiedSubtitle.replacingCharacters(in: range, with: "")
        }
        return modifiedSubtitle.trimmingCharacters(in: .whitespaces)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
// 내위치
extension ArriveModalViewController: CLLocationManagerDelegate {
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first else { return }
            
            let address = self.formatAddress(from: placemark)
            self.delegate?.arriveModalViewController(self, didSelectAddress: address)
            self.dismiss(animated: true, completion: nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        if let subThoroughfare = placemark.subThoroughfare {
            addressComponents.append(subThoroughfare)
        }
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        if let subLocality = placemark.subLocality {
            addressComponents.append(subLocality)
        }
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        return addressComponents.joined(separator: " ")
    }
}
