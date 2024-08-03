//
//  MainViewController.swift
//  WheelBus
//
//  Created by 김현중 on 8/1/24.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    var frequentRoutes: [FrequentRoute] = []
    
    var departurePlaceholder = "출발지 입력"
    var arrivePlaceholder = "도착지 입력"
    var departureValue: String?
    var arriveValue: String?
    
    var departureLat: Float = 0.0
    var departureLon: Float = 0.0
    var arriveLat: Float = 0.0
    var arriveLon: Float = 0.0
    
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
        print("edit buttopn tapped")
        let modalViewController = EditViewController()
        modalViewController.modalPresentationStyle = .fullScreen
        self.present(modalViewController, animated: true)
    }
    
    func fetchFrequentRoutes() {
        // 여기에 서버에서 데이터를 가져오는 로직을 구현합니다.
        // 예시:
        let newRoutes = [
            FrequentRoute(startStation: "스타벅스 포항양덕지점", endStation: "강남역", busNumber: "9401"),
            FrequentRoute(startStation: "홍대입구", endStation: "여의도", busNumber: "7711"),
            FrequentRoute(startStation: "서울역", endStation: "강남역", busNumber: "9401"),
            FrequentRoute(startStation: "홍대입구", endStation: "여의도", busNumber: "7711"),
            FrequentRoute(startStation: "서울역", endStation: "강남역", busNumber: "9401"),
            FrequentRoute(startStation: "홍대입구", endStation: "여의도", busNumber: "7711")
        ]
        
        frequentRoutes.append(contentsOf: newRoutes)
        updateEmptyState()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.968, green: 0.968, blue: 0.968, alpha: 1)

        
        recommendedRouteTableView.delegate = self
        recommendedRouteTableView.dataSource = self
        
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
        searchview.addSubview(changeButton)
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

            recommendedRouteLabel.topAnchor.constraint(equalTo: recommendedRouteView.topAnchor, constant: 10),
            recommendedRouteLabel.leadingAnchor.constraint(equalTo: recommendedRouteView.leadingAnchor, constant: 30),

            recommendedRouteTableView.topAnchor.constraint(equalTo: recommendedRouteView.topAnchor, constant: 60),
            recommendedRouteTableView.leadingAnchor.constraint(equalTo: recommendedRouteView.leadingAnchor),
            recommendedRouteTableView.trailingAnchor.constraint(equalTo: recommendedRouteView.trailingAnchor),
            recommendedRouteTableView.bottomAnchor.constraint(equalTo: recommendedRouteView.bottomAnchor)
        ])
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
}
// 출발, 도착 값 있을 떄 따는 tableview 관리
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 // 예시로 5개의 셀을 표시
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendedRouteCell", for: indexPath)
        cell.textLabel?.text = "추천 경로 \(indexPath.row + 1)"
        return cell
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
