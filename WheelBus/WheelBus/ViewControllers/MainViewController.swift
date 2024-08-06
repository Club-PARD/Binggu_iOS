//
//  MainViewController.swift
//  WheelBus
//
//  Created by 김현중 on 8/1/24.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, EditViewControllerDelegate {
    var userId: Int64?
    
    var frequentRoutes: [FrequentRoute] = []
    
    var departurePlaceholder = "출발지 입력"
    var arrivePlaceholder = "도착지 입력"
    var departureValue: String?
    var arriveValue: String?
    
    var departureLat: Float = 0.0
    var departureLon: Float = 0.0
    var arriveLat: Float = 0.0
    var arriveLon: Float = 0.0
    
    var stationId: String = "DGB7011010100"
    var routeId: String = "DGB3000503000"
    var stationId2: String = "DGB7041024200"
    var routeId2: String = "DGB3000509000"
    
    var walkTime1Route1: Int?
    var walkTime2Route1: Int?
    var busTimeRoute1: Int?
    var walkTime1Route2: Int?
    var walkTime2Route2: Int?
    var busTimeRoute2: Int?
    var finalStationRoute1: String?
    var firstStationRoute1: String?
    var busNumRoute1: Int?
    var finalStationRoute2: String?
    var firstStationRoute2: String?
    var busNumRoute2: Int?
    
    var walkadd1: Int?
    var walkadd2: Int?
    var addall1: Int?
    var addall2: Int?
    
    var menuBackgroundView: UIView!
    var menuView: UIView!
    var privacyLabel: UILabel!
    var termsLabel: UILabel!
    
    func setupMenuView() {
        // Setup background view
        menuBackgroundView = UIView(frame: self.view.bounds)
        menuBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        menuBackgroundView.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeMenu))
        menuBackgroundView.addGestureRecognizer(tapGesture)

        let menuWidth = self.view.frame.width / 1.5
        menuView = UIView(frame: CGRect(x: self.view.frame.width, y: 0, width: menuWidth, height: self.view.frame.height))
        menuView.backgroundColor = UIColor.white
        
        privacyLabel = createMenuLabel(text: "개인정보처리방침")
        termsLabel = createMenuLabel(text: "이용약관")
        
        menuView.addSubview(privacyLabel)
        menuView.addSubview(termsLabel)
        
        // Layout constraints for labels
        NSLayoutConstraint.activate([
            privacyLabel.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 127),
            privacyLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 40),
            
            termsLabel.topAnchor.constraint(equalTo: privacyLabel.bottomAnchor, constant: 35),
            termsLabel.leadingAnchor.constraint(equalTo: privacyLabel.leadingAnchor)
        ])
        
        // Add views to main view
        self.view.addSubview(menuBackgroundView)
        self.view.addSubview(menuView)
    }

    func createMenuLabel(text: String) -> UILabel {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 122, height: 11)
        label.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        label.font = UIFont(name: "NanumSquareNeo-Bold", size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.9
        label.attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    @objc func menuButtonTapped() {
        setupMenuView()
        UIView.animate(withDuration: 0.3) {
            self.menuBackgroundView.alpha = 1
            self.menuView.frame.origin.x = self.view.frame.width / 2
        }
    }

    @objc func closeMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.menuBackgroundView.alpha = 0
            self.menuView.frame.origin.x = self.view.frame.width
        }) { _ in
            self.menuBackgroundView.removeFromSuperview()
            self.menuView.removeFromSuperview()
        }
    }
    
    func convertAddressToCoordinates(address: String, isArrival: Bool) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                print("No coordinates found for the address")
                return
            }
            
            if isArrival {
                self.arriveLat = Float(location.coordinate.latitude)
                self.arriveLon = Float(location.coordinate.longitude)
                print("Arrival Coordinates: \(self.arriveLat), \(self.arriveLon)")
            } else {
                self.departureLat = Float(location.coordinate.latitude)
                self.departureLon = Float(location.coordinate.longitude)
                print("Departure Coordinates: \(self.departureLat), \(self.departureLon)")
            }
        }
    }

    let topview : UIView = {
        let top = UIView()
        top.translatesAutoresizingMaskIntoConstraints = false
        top.layer.backgroundColor = #colorLiteral(red: 0, green: 0.4780646563, blue: 0.9985368848, alpha: 1)
        return top
    }()
    
    let bottomview : UIView = {
        let bottom = UIView()
        bottom.translatesAutoresizingMaskIntoConstraints = false
        bottom.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        return bottom
    }()
    
    let logoimage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill //
        imageView.clipsToBounds = false // 뷰의 경계 벗어나도 괜찮게
        imageView.image = UIImage(named: "main")
        return imageView
    }()
    
    
    let menuImage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Menu")
        return imageView
    }()
    
    var titlelabel : UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = ("WheelBus")
        title.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        title.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
        return title
    }()
    
    var secondtext: UILabel = {
        let label = UILabel()
        let fullText = "오늘은 어디로 \n가볼까요?"
        
        // NSAttributedString으로 텍스트 설정
        let attributedText = NSMutableAttributedString(string: fullText)
        
        // "오늘은 어디로" 부분의 글꼴과 속성 설정
        let firstRange = (fullText as NSString).range(of: "오늘은 어디로")
        let regularFont = UIFont.nanumSquareNeo(.regular, size: 32)
        attributedText.addAttribute(.font, value: regularFont, range: firstRange)
        
        // "가볼까요?" 부분의 글꼴과 속성 설정
        let secondRange = (fullText as NSString).range(of: "가볼까요?")
        let boldFont = UIFont.nanumSquareNeo(.bold, size: 32)
        attributedText.addAttribute(.font, value: boldFont, range: secondRange)
        
        // 줄 간격 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10 // 원하는 줄 간격으로 조절
        
        // 전체 텍스트에 줄 간격 적용
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        
        // UILabel에 속성 텍스트 설정
        label.attributedText = attributedText
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let searchview : UIView = {
        let search = UIView()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.backgroundColor = .white
        search.layer.cornerRadius = 12
        search.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        search.layer.shadowOpacity = 1
        search.layer.shadowRadius = 20
        search.layer.masksToBounds = false //view 경계 넘는 부분 자르지 않게 해주기. 이렇게 해야 그림자 보임
        return search
    }()
    
    let barimage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill //
        imageView.clipsToBounds = false // 뷰의 경계 벗어나도 괜찮게
        imageView.image = UIImage(named: "line")
        return imageView
    }()
    
    var line: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(red: 0.908, green: 0.908, blue: 0.908, alpha: 1)
        return line
    }()
    
    let changeButton : UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .clear
        config.imagePlacement = .all
        
        if let image = UIImage(named: "change"){
            let size = CGSize(width: 33, height: 33)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            config.image = scaledImage
        }
        
        let button  = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // 출발지 입력칸
    let departureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.nanumSquareNeo(.regular, size: 22)
        label.textColor = .lightGray
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // 도착지 입력칸
    let arriveLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.nanumSquareNeo(.regular, size: 22)
        label.textColor = .lightGray
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let frequentRoutesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "자주 가는 길"
        label.font = UIFont.nanumSquareNeo(.extraBold, size: 20)
        label.textColor = .black
        return label
    }()
    
    let editbutton : UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .clear
        
        config.title = "편집"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.nanumSquareNeo(.regular, size: 15)
            outgoing.foregroundColor = #colorLiteral(red: 0.5843136907, green: 0.5843136907, blue: 0.5843136907, alpha: 1)
            return outgoing
        }
        
        var button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(editbuttontaped), for: .touchUpInside)
        
        return button
    }()
    //즐겨찾기 값 뜨는 collectionview
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(FrequentRouteCell.self, forCellWithReuseIdentifier: "FrequentRouteCell")
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    // 즐겨찾기 등록된 값 없을 때 나타나는 곳
    let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "자주가는 길을 등록해보세요."
        label.font = UIFont.nanumSquareNeo(.bold, size: 17)
        label.textColor = #colorLiteral(red: 0.5843136907, green: 0.5843136907, blue: 0.5843136907, alpha: 1)
        return label
    }()
    
    let emptyStateLabel2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let fullText = "자주 이용하는 길을 등록하고, \n언제든지 편하게 저상버스를 이용하세요!"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        
        let attributedText = NSMutableAttributedString(string: fullText)
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        attributedText.addAttribute(.font, value: UIFont.nanumSquareNeo(.bold, size: 14), range: NSMakeRange(0, attributedText.length))
        attributedText.addAttribute(.foregroundColor, value: UIColor(red: 0.7803922296, green: 0.7803922296, blue: 0.7803922296, alpha: 1), range: NSMakeRange(0, attributedText.length))
        
        label.attributedText = attributedText
        label.numberOfLines = 2
        label.textAlignment = .center
        
        return label
    }()
    
    let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "empty")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    //    출발, 도착 값이 다 담기면 나타나는 부분
    let recommendedRouteView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.isHidden = true // 초기에는 숨김 상태
        return view
    }()
    
    let recommendedRouteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "추천하는 길"
        label.font = UIFont.nanumSquareNeo(.extraBold, size: 20)
        label.textColor = .black
        return label
    }()
    
    let recommendedRouteTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecommendedRouteCell")
        return tableView
    }()
    
    
    @objc func departureLabelTapped() {
        let modalVC = DepartureModalViewController()
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .formSheet
        
        // detent 설정
        if let sheet = modalVC.sheetPresentationController {
            // detents 배열을 설정하여 원하는 위치에 맞게 모달 창의 위치를 조정할 수 있습니다.
            sheet.detents = [
                .custom { _ in
                    return self.view.frame.height * 0.72  //이 숫자로 원하는 만큼 조절가능
                }
            ]
            
            sheet.preferredCornerRadius = 19 // 모달 창의 모서리 둥글기 설정
            //            sheet.prefersScrollingExpandsWhenScrolledToEdge = true // full일 때 스크롤 시 창 크기 조정
            
            present(modalVC, animated: true, completion: nil)
        }
    }
    
    @objc func arriveLabelTapped() {
        let modalVC = ArriveModalViewController()
        modalVC.delegate = self
        modalVC.modalPresentationStyle = .formSheet
        
        // detent 설정
        if let sheet = modalVC.sheetPresentationController {
            // detents 배열을 설정하여 원하는 위치에 맞게 모달 창의 위치를 조정할 수 있습니다.
            sheet.detents = [
                .custom { _ in
                    return self.view.frame.height * 0.72  //이 숫자로 원하는 만큼 조절가능
                }
            ]
            
            sheet.preferredCornerRadius = 19 // 모달 창의 모서리 둥글기 설정
            //            sheet.prefersScrollingExpandsWhenScrolledToEdge = true // full일 때 스크롤 시 창 크기 조정
            
            present(modalVC, animated: true, completion: nil)
        }
    }
    
    func updateDepartureLabel() {
        if let value = departureValue, !value.isEmpty {
            departureLabel.text = value
            departureLabel.font = UIFont.nanumSquareNeo(.bold, size: 18)
            departureLabel.textColor = .black
        } else {
            departureLabel.text = departurePlaceholder
            departureLabel.font = UIFont.nanumSquareNeo(.regular, size: 22)
            departureLabel.textColor = .lightGray
        }
        updateResetButtonVisibility()
        updateRecommendedRouteView()
    }
    
    func updateArriveLabel() {
        if let value = arriveValue, !value.isEmpty {
            arriveLabel.text = value
            arriveLabel.font = UIFont.nanumSquareNeo(.bold, size: 18)
            arriveLabel.textColor = .black
        } else {
            arriveLabel.text = arrivePlaceholder
            arriveLabel.font = UIFont.nanumSquareNeo(.regular, size: 22)
            arriveLabel.textColor = .lightGray
        }
        updateResetButtonVisibility()
        updateRecommendedRouteView()
    }
    //출발, 도착 두 값이 모두 있는지 확인해서 있으면 이 함수 실행
    func updateRecommendedRouteView() {
        if let departure = departureValue, let arrive = arriveValue,
           !departure.isEmpty && !arrive.isEmpty {
            recommendedRouteView.isHidden = false
            bottomview.isHidden = true
            // 둘 다 값 들어있으면 이걸로 위도 경도 받아오기
            convertAddressToCoordinates(address: departureValue!, isArrival: false)
            convertAddressToCoordinates(address: arriveValue!, isArrival: true)
            
            //여기서 위도, 경도 전송도 해주면 되겠다.
            
            
        } else {
            recommendedRouteView.isHidden = true
            bottomview.isHidden = false
        }
    }
    
    func swapDepartureAndArriveValues() {
        let tempDeparture = departureValue
        let tempArrive = arriveValue
        
        // 출발지 값이 있고 도착지 값이 없는 경우
        if tempDeparture != nil && tempArrive == nil {
            departureValue = nil
            arriveValue = tempDeparture
        }
        // 도착지 값이 있고 출발지 값이 없는 경우
        else if tempArrive != nil && tempDeparture == nil {
            departureValue = tempArrive
            arriveValue = nil
        }
        // 둘 다 값이 있는 경우
        else if tempDeparture != nil && tempArrive != nil {
            departureValue = tempArrive
            arriveValue = tempDeparture
        }
        // 둘 다 값이 없는 경우는 아무 것도 하지 않음
        
        DispatchQueue.main.async { [weak self] in
            self?.updateDepartureLabel()
            self?.updateArriveLabel()
        }
    }
    
    
    @objc func changeButtonTapped() {
        print("button tapped")
        swapDepartureAndArriveValues()
    }
    
    @objc func editbuttontaped() {
        print("edit button tapped")
        let modalViewController = EditViewController()
        modalViewController.delegate = self
        modalViewController.userId = self.userId
        modalViewController.modalPresentationStyle = .fullScreen
        self.present(modalViewController, animated: true)
    }
    
    func fetchFrequentRoutes() {
        guard let userId = userId else {
            print("User ID is not available")
            return
        }
        
        let urlString = "http://ec2-3-34-193-237.ap-northeast-2.compute.amazonaws.com:8080/user/\(userId)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let routes = json["routes"] as? [String: [String: [String]]] {
                    var newRoutes: [FrequentRoute] = []
                    
                    for (busNumber, routeInfo) in routes {
                        if let route = routeInfo["route"],
                           route.count >= 2 {
                            let startStation = route[0]
                            let endStation = route[1]
                            let frequentRoute = FrequentRoute(startStation: startStation, endStation: endStation, busNumber: busNumber)
                            newRoutes.append(frequentRoute)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.frequentRoutes = newRoutes
                        self.updateEmptyState()
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    @objc func calculationsCompleted() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // AppDelegate의 값을 MainViewController의 변수에 할당
        self.walkTime1Route1 = appDelegate.walkTime1Route1
        self.walkTime2Route1 = appDelegate.walkTime2Route1
        self.busTimeRoute1 = appDelegate.busTimeRoute1
        self.walkTime1Route2 = appDelegate.walkTime1Route2
        self.walkTime2Route2 = appDelegate.walkTime2Route2
        self.busTimeRoute2 = appDelegate.busTimeRoute2
        self.finalStationRoute1 = appDelegate.finalStationRoute1
        self.firstStationRoute1 = appDelegate.firstStationRoute1
        self.finalStationRoute2 = appDelegate.finalStationRoute2
        self.firstStationRoute2 = appDelegate.firstStationRoute2

        if let busNumString1 = appDelegate.busNumRoute1 {
            self.busNumRoute1 = Int(busNumString1)
        }

        // busNumRoute2 변환 및 할당
        if let busNumString2 = appDelegate.busNumRoute2 {
            self.busNumRoute2 = Int(busNumString2)
        }
  
        if let walkTime1Route1 = appDelegate.walkTime1Route1,
           let walkTime2Route1 = appDelegate.walkTime2Route1 {
            self.walkadd1 = walkTime1Route1 + walkTime2Route1
        } else {
            // 둘 중 하나라도 nil인 경우 처리
            self.walkadd1 = 0 // 또는 다른 기본값
        }
        
        if let walkTime1Route2 = appDelegate.walkTime1Route2,
           let walkTime2Route2 = appDelegate.walkTime2Route2 {
            self.walkadd2 = walkTime1Route2 + walkTime2Route2
        } else {
            // 둘 중 하나라도 nil인 경우 처리
            self.walkadd2 = 0 // 또는 다른 기본값
        }
        
        if let walkTime1Route1 = appDelegate.walkTime1Route1,
           let walkTime2Route1 = appDelegate.walkTime2Route1,
           let busTimeRoute1 = appDelegate.busTimeRoute1 {
            self.addall1 = walkTime1Route1 + walkTime2Route1 + busTimeRoute1
        } else {
            // 둘 중 하나라도 nil인 경우 처리
            self.addall1 = 0 // 또는 다른 기본값
        }
        
        if let walkTime1Route2 = appDelegate.walkTime1Route2,
           let walkTime2Route2 = appDelegate.walkTime2Route2,
           let busTimeRoute2 = appDelegate.busTimeRoute2 {
            self.addall2 = walkTime1Route2 + walkTime2Route2 + busTimeRoute2
        } else {
            // 둘 중 하나라도 nil인 경우 처리
            self.addall2 = 0 // 또는 다른 기본값
        }
        
        
        
        
        
        
        
        
        
        
        //            // 값이 할당된 후 필요한 작업 수행
        //            print("All calculations completed and values assigned")
        //            logAllVariables()
        //            updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calculationsCompleted()
        
        view.backgroundColor = UIColor(red: 0.968, green: 0.968, blue: 0.968, alpha: 1)
        
        print("\(userId)")
        
        recommendedRouteTableView.separatorStyle = .none
        recommendedRouteTableView.delegate = self
        recommendedRouteTableView.dataSource = self
        recommendedRouteTableView.register(RouteRecommendCell.self, forCellReuseIdentifier: "RouteRecommendCell")
        
        setUI()
        updateEmptyState()
        fetchFrequentRoutes()
        
        updateDepartureLabel()
        updateArriveLabel()
        
        let departureTapGesture = UITapGestureRecognizer(target: self, action: #selector(departureLabelTapped))
        departureLabel.addGestureRecognizer(departureTapGesture)
        
        let arriveTapGesture = UITapGestureRecognizer(target: self, action: #selector(arriveLabelTapped))
        arriveLabel.addGestureRecognizer(arriveTapGesture)
    }
    
    let resetButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Reset"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        button.clipsToBounds = true
        button.layer.cornerRadius = 12
        button.layer.maskedCorners = [.layerMaxXMaxYCorner]
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    func setUI() {
        view.addSubview(topview)
        view.addSubview(bottomview)
        view.addSubview(searchview)
        searchview.addSubview(line)
        searchview.addSubview(departureLabel)
        searchview.addSubview(arriveLabel)
        searchview.addSubview(barimage)
        topview.addSubview(logoimage)
        topview.addSubview(titlelabel)
        topview.addSubview(secondtext)
        topview.addSubview(menuImage)
        searchview.addSubview(changeButton)
        searchview.addSubview(resetButton)
        bottomview.addSubview(frequentRoutesLabel)
        bottomview.addSubview(collectionView)
        bottomview.addSubview(emptyStateView)
        bottomview.addSubview(editbutton)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateLabel2)
        emptyStateView.addSubview(emptyStateImageView)
        view.addSubview(recommendedRouteView)
        recommendedRouteView.addSubview(recommendedRouteLabel)
        recommendedRouteView.addSubview(recommendedRouteTableView)

        NSLayoutConstraint.activate([
            topview.topAnchor.constraint(equalTo: view.topAnchor),
            topview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.39),
            
            bottomview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomview.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            logoimage.bottomAnchor.constraint(equalTo: topview.bottomAnchor, constant: -40),
            logoimage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logoimage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logoimage.topAnchor.constraint(equalTo: topview.topAnchor, constant: 0),
            
            titlelabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.1),
            titlelabel.leadingAnchor.constraint(equalTo: searchview.leadingAnchor),
            titlelabel.heightAnchor.constraint(equalToConstant: 17),
            
            menuImage.widthAnchor.constraint(equalToConstant: 24),
            menuImage.heightAnchor.constraint(equalToConstant: 24),
            menuImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
            menuImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            
            secondtext.leadingAnchor.constraint(equalTo: searchview.leadingAnchor),
            secondtext.heightAnchor.constraint(equalToConstant: 96),
            secondtext.bottomAnchor.constraint(equalTo: searchview.topAnchor, constant: -28),
            
            searchview.centerYAnchor.constraint(equalTo: topview.bottomAnchor, constant: -5),
            searchview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width * 0.077),
            searchview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.frame.width * 0.077),
            searchview.heightAnchor.constraint(equalToConstant: view.frame.height * 0.176),
            
            barimage.centerYAnchor.constraint(equalTo: searchview.centerYAnchor),
            barimage.trailingAnchor.constraint(equalTo: line.leadingAnchor, constant: -22),
            
            line.centerYAnchor.constraint(equalTo: searchview.centerYAnchor),
            line.leadingAnchor.constraint(equalTo: searchview.leadingAnchor, constant: 64),
            line.trailingAnchor.constraint(equalTo: searchview.trailingAnchor, constant: -22),
            line.heightAnchor.constraint(equalToConstant: 2),
            
            departureLabel.bottomAnchor.constraint(equalTo: line.topAnchor, constant: -22),
            departureLabel.leadingAnchor.constraint(equalTo: line.leadingAnchor),
            departureLabel.trailingAnchor.constraint(equalTo: searchview.trailingAnchor, constant: -75),
            departureLabel.heightAnchor.constraint(equalToConstant: 22),
            
            arriveLabel.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 22),
            arriveLabel.leadingAnchor.constraint(equalTo: line.leadingAnchor),
            arriveLabel.trailingAnchor.constraint(equalTo: searchview.trailingAnchor, constant: -75),
            
            changeButton.centerYAnchor.constraint(equalTo: line.centerYAnchor),
            changeButton.trailingAnchor.constraint(equalTo: searchview.trailingAnchor, constant: -35),
            
            frequentRoutesLabel.topAnchor.constraint(equalTo: bottomview.topAnchor, constant: 20),
            frequentRoutesLabel.leadingAnchor.constraint(equalTo: searchview.leadingAnchor),
            
            editbutton.topAnchor.constraint(equalTo: bottomview.topAnchor, constant: 20),
            editbutton.trailingAnchor.constraint(equalTo: searchview.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: frequentRoutesLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: bottomview.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: bottomview.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 170),
            
            emptyStateView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor, constant: -50),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 10),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            emptyStateLabel2.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 10),
            emptyStateLabel2.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 55),
            
            recommendedRouteView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            recommendedRouteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recommendedRouteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recommendedRouteView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            recommendedRouteLabel.topAnchor.constraint(equalTo: recommendedRouteView.topAnchor, constant: 13),
            recommendedRouteLabel.leadingAnchor.constraint(equalTo: recommendedRouteView.leadingAnchor, constant: 30),
            
            recommendedRouteTableView.topAnchor.constraint(equalTo: recommendedRouteView.topAnchor, constant: 60),
            recommendedRouteTableView.leadingAnchor.constraint(equalTo: recommendedRouteView.leadingAnchor),
            recommendedRouteTableView.trailingAnchor.constraint(equalTo: recommendedRouteView.trailingAnchor),
            recommendedRouteTableView.bottomAnchor.constraint(equalTo: recommendedRouteView.bottomAnchor),
            
            resetButton.bottomAnchor.constraint(equalTo: searchview.bottomAnchor),
            resetButton.trailingAnchor.constraint(equalTo: searchview.trailingAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 66),
            resetButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        let menuTapGesture = UITapGestureRecognizer(target: self, action: #selector(menuButtonTapped))
        menuImage.isUserInteractionEnabled = true
        menuImage.addGestureRecognizer(menuTapGesture)
    }
    
    @objc func resetButtonTapped() {
        departureLabel.text = departurePlaceholder
        arriveLabel.text = arrivePlaceholder
        departureValue = nil
        arriveValue = nil
        updateDepartureLabel()
        updateArriveLabel()
        updateResetButtonVisibility()
        
        refreshViewController()
    }
    
    func refreshViewController() {
        // 자주 가는 길 데이터 다시 불러오기
        fetchFrequentRoutes()
    }
    
    func updateResetButtonVisibility() {
        let shouldShow = departureValue != nil || arriveValue != nil
        
        UIView.animate(withDuration: 0.3) {
            self.resetButton.alpha = shouldShow ? 1 : 0
        }
    }
    
    func updateEmptyState() {
        emptyStateView.isHidden = !frequentRoutes.isEmpty
        collectionView.isHidden = frequentRoutes.isEmpty
    }
}

// 즐겨찾기 collectionview관리
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frequentRoutes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrequentRouteCell", for: indexPath) as! FrequentRouteCell
        cell.configure(with: frequentRoutes[indexPath.item])
        
        // Cell 디자인 수정
        cell.contentView.backgroundColor = UIColor(red: 0.992, green: 0.992, blue: 0.992, alpha: 1)
        cell.contentView.layer.cornerRadius = 8 // 모서리 둥글게
        cell.contentView.layer.borderWidth = 2 // 테두리 굵기
        cell.contentView.layer.borderColor = UIColor(red: 0.951, green: 0.953, blue: 0.957, alpha: 1).cgColor
        cell.contentView.layer.masksToBounds = true // 내용이 셀의 경계를 넘지 않도록 설정
        
        cell.layer.masksToBounds = true // cell 자체에도 설정
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 204, height: 152)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: view.frame.width * 0.077, bottom: 0, right: view.frame.width * 0.077)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12 // 가로 간격
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let mainVC = MapViewController()
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true, completion: nil)
        case 1:
            let mainVC = MapViewController2()
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true, completion: nil)
        default:
            break
        }
    }
}
// 출발, 도착 값 있을 떄 따는 tableview 관리
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // 예시로 5개의 셀을 표시
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RouteRecommendCell", for: indexPath) as? RouteRecommendCell else {
            fatalError("Unable to dequeue RouteRecommendCell")
        }
        cell.backgroundColor = #colorLiteral(red: 0.9750779271, green: 0.9750778079, blue: 0.9750779271, alpha: 1)
        cell.selectionStyle = .none
        
        cell.delegate = self
        print("Cell delegate set")  // 디버깅 메시지 추가
        
        // 여기에서 각 셀에 대한 데이터를 설정합니다.
        switch indexPath.row {
        case 0:
            cell.configure(totalTime: addall1!,
                           wheelWalkTime: walkadd1!,
                           firstWalkTime: walkTime1Route1!,
                           busTime: busTimeRoute1!,
                           finalWalkTime: walkTime2Route1!,
                           busNumber: busNumRoute1!,
                           startBusStop: firstStationRoute1!,
                           endBusStop: finalStationRoute1!,
                           stationId: self.stationId,
                           routeId: self.routeId)
        case 1:
            cell.configure(totalTime: addall2!,
                           wheelWalkTime: walkadd2!,
                           firstWalkTime: walkTime1Route2!,
                           busTime: busTimeRoute2!,
                           finalWalkTime: walkTime2Route2!,
                               busNumber: busNumRoute2!,
                               startBusStop: firstStationRoute2!,
                               endBusStop: finalStationRoute2!,
                               stationId: self.stationId2,
                               routeId: self.routeId2)
            default:
                // 기본 데이터 설정 (필요한 경우)
                cell.configure(totalTime: 0,
                               wheelWalkTime: 0,
                               firstWalkTime: 0,
                               busTime: 0,
                               finalWalkTime: 0,
                               busNumber: 0,
                               startBusStop: "",
                               endBusStop: "",
                               stationId: "",
                               routeId: "")
            }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let mainVC = MapViewController()
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true, completion: nil)
        case 1:
            let mainVC = MapViewController2()
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension MainViewController: RouteRecommendCellDelegate {
    func routeRecommendCell(_ cell: RouteRecommendCell, didTapAddRoutineButton isSelected: Bool, routeId: Int, startStation: String, endStation: String) {
        if isSelected {
            sendRouteInfoToServer(routeId: routeId, startStation: startStation, endStation: endStation)
        } else {
            deleteRouteFromServer(routeId: routeId)
        }
        print("Delegate method called. isSelected: \(isSelected)")
        let message = isSelected ? "자주 가는 길로 등록되었습니다." : "자주 가는 길이 해제되었습니다."
        let image = isSelected ? UIImage(named: "checkmark") : UIImage(named: "cross")
        showSnackbarWithImage(message: message, image: image)
    }
    
    private func showSnackbarWithImage(message: String, image: UIImage?) {
        print("Attempting to show snackbar with message: \(message)")
        
        DispatchQueue.main.async {
            let snackbar = UIView()
            snackbar.backgroundColor = UIColor(red: 0.224, green: 0.224, blue: 0.224, alpha: 0.95)
            snackbar.layer.cornerRadius = 4
            snackbar.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = message
            label.textColor = .white // 변경: 텍스트 색상을 흰색으로 설정
            label.font = UIFont.nanumSquareNeo(.bold, size: 15)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            snackbar.addSubview(imageView)
            snackbar.addSubview(label)
            self.view.addSubview(snackbar)
            
            NSLayoutConstraint.activate([
                snackbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
                snackbar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                snackbar.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -34),
                snackbar.heightAnchor.constraint(equalToConstant: 60), // 고정 높이 설정
                
                imageView.leadingAnchor.constraint(equalTo: snackbar.leadingAnchor, constant: 16),
                imageView.centerYAnchor.constraint(equalTo: snackbar.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 24),
                imageView.heightAnchor.constraint(equalToConstant: 24),
                
                label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
                label.trailingAnchor.constraint(equalTo: snackbar.trailingAnchor, constant: -16),
                label.centerYAnchor.constraint(equalTo: snackbar.centerYAnchor)
            ])
            
            snackbar.alpha = 0
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.3, animations: {
                snackbar.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut, animations: {
                    snackbar.alpha = 0
                }) { _ in
                    snackbar.removeFromSuperview()
                }
            }
        }
    }
    func sendRouteInfoToServer(routeId: Int, startStation: String, endStation: String) {
        guard let userId = userId else {
            print("User ID is not available")
            return
        }

        guard let url = URL(string: "http://ec2-3-34-193-237.ap-northeast-2.compute.amazonaws.com:8080/user/\(userId)") else { return }
        
        let parameters: [String: Any] = [
            "routeId": routeId,
            "route": [
                "route": [startStation, endStation]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error: unable to serialize parameters")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
        }.resume()
    }
    // 즐겨찾기 해제
    func deleteRouteFromServer(routeId: Int) {
        guard let userId = userId else {
            print("User ID is not available")
            return
        }
        
        guard let url = URL(string: "http://ec2-3-34-193-237.ap-northeast-2.compute.amazonaws.com:8080/user/\(userId)/\(routeId)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    print("Route successfully deleted from server")
                } else {
                    print("Failed to delete route from server")
                }
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data: \(dataString)")
            }
        }.resume()
    }
}

//delegate 프로토콜 채택 및 구현
extension MainViewController: DepartureModalViewControllerDelegate {
    func departureModalViewController(_ viewController: DepartureModalViewController, didSelectAddress address: String) {
        departureLabel.text = address
        departureValue = address
        updateDepartureLabel()
    }
}

extension MainViewController: ArriveModalViewControllerDelegate {
    func arriveModalViewController(_ viewController: ArriveModalViewController, didSelectAddress address: String) {
        arriveLabel.text = address
        arriveValue = address
        updateArriveLabel()
    }
}

struct FrequentRoute {
    let startStation: String
    let endStation: String
    let busNumber: String
}
