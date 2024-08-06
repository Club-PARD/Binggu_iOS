//
//  RouteRecommendCell.swift
//  WheelBus
//
//  Created by 유재혁 on 8/4/24.
//


import UIKit

protocol RouteRecommendCellDelegate: AnyObject {
    func routeRecommendCell(_ cell: RouteRecommendCell, didTapAddRoutineButton isSelected: Bool, routeId: Int, startStation: String, endStation: String)
}

class RouteRecommendCell: UITableViewCell {
    private let minSegmentWidth: CGFloat = 40
    weak var delegate: RouteRecommendCellDelegate?
    
    var routeId: Int?
    var startStation: String?
    var endStation: String?
    
    //1분마다 시간 불러오기위해서
    private var updateTimer: Timer?
    private var currentStationId: String?
    private var currentRouteId: String?
    
    //1분마다 불러오기위해서 타이머 설정하는 함수
    func fetchBusArrivalInfo(stationId: String, routeId: String) {
        // 기존 stationId와 routeId가 다르면 타이머를 초기화합니다.
        if stationId != currentStationId || routeId != currentRouteId {
            updateTimer?.invalidate()
            currentStationId = stationId
            currentRouteId = routeId
            
            // 새로운 타이머 설정
            updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
                self?.fetchBusArrivalInfoFromServer()
            }
        }
        
        // 즉시 한 번 실행
        fetchBusArrivalInfoFromServer()
    }
    
    private func fetchBusArrivalInfoFromServer() {
        guard let stationId = currentStationId, let routeId = currentRouteId else { return }
        
        let urlString = "http://ec2-3-34-193-237.ap-northeast-2.compute.amazonaws.com:8080/bus/arrivalTime"
        guard let url = URL(string: urlString) else { return }
        
        let parameters: [String: Any] = [
            "stationId": stationId,
            "routeId": routeId
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
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                DispatchQueue.main.async {
                    self.busArrivalInfoLabel.text = "도착 예정 정보없음"
                    self.busArrivalInfoLabel.textColor = UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1)
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let arrivalMin = json["arrivalMin"] as? Int {
                    DispatchQueue.main.async {
                        self.busArrivalInfoLabel.text = "\(arrivalMin)분 후 도착예정"
                        self.busArrivalInfoLabel.textColor = .red
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1)
        label.font = UIFont(name: "NotoSansKR-Medium", size: 11)
        label.text = "총 소요시간"
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        label.font = UIFont(name: "NotoSansKR-Medium", size: 32) ?? UIFont.systemFont(ofSize: 16)
        label.text = ""
        return label
    }()
    
    private let wheelWalkTimeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Wheelrun")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let wheelWalkTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "NanumSquareNeo-Bold", size: 12)
        label.text = "휠워크"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private var routeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var addRoutineButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "routineIcon"), for: .normal)
        button.setImage(UIImage(named: "routineIconSelected"), for: .selected)
        button.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(addRoutineButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let busRoutineSummaryImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "line2")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let busNumImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "littlebus")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let busNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0, green: 0.3, blue: 1, alpha: 1)
        label.font = UIFont.nanumSquareNeo(.extraBold, size: 22)
        label.textAlignment = .center
        label.text = ""
        return label
    }()
    
    private let startBusStopNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        label.font = UIFont.nanumSquareNeo(.bold, size: 15)
        label.text = ""
        return label
    }()
    
    private let endBusStopNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        label.font = UIFont.nanumSquareNeo(.bold, size: 15)
        label.text = ""
        return label
    }()
    
    private let busArrivalInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1)
        label.font = UIFont.nanumSquareNeo(.bold, size: 15)
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        label.attributedText = NSAttributedString(string: "도착 예정 정보없음", attributes: [
            .kern: -0.3,
            .paragraphStyle: paragraphStyle
        ])
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        
        contentView.addSubview(totalTimeLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(wheelWalkTimeImage)
        contentView.addSubview(wheelWalkTimeLabel)
        contentView.addSubview(routeStackView)
        contentView.addSubview(addRoutineButton)
        contentView.addSubview(busRoutineSummaryImage)
        contentView.addSubview(busNumImage)
        contentView.addSubview(busNumberLabel)
        contentView.addSubview(startBusStopNameLabel)
        contentView.addSubview(endBusStopNameLabel)
        contentView.addSubview(busArrivalInfoLabel)
        
        NSLayoutConstraint.activate([
            totalTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            totalTimeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            timeLabel.topAnchor.constraint(equalTo: totalTimeLabel.bottomAnchor, constant: 2),
            timeLabel.heightAnchor.constraint(equalToConstant: 30),
            
            wheelWalkTimeImage.trailingAnchor.constraint(equalTo: wheelWalkTimeLabel.leadingAnchor, constant: -5.41),
            wheelWalkTimeImage.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor),
            wheelWalkTimeImage.widthAnchor.constraint(equalToConstant: 19),
            wheelWalkTimeImage.heightAnchor.constraint(equalToConstant: 16),
            
            wheelWalkTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -36.19),
            wheelWalkTimeLabel.centerYAnchor.constraint(equalTo: wheelWalkTimeImage.centerYAnchor),
            wheelWalkTimeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 67),
            
            routeStackView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 23.34),
            routeStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30.5),
            routeStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.5),
            routeStackView.heightAnchor.constraint(equalToConstant: 24),
            
            addRoutineButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -19),
            addRoutineButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -31),
            addRoutineButton.widthAnchor.constraint(equalToConstant: 100),
            addRoutineButton.heightAnchor.constraint(equalToConstant: 34),
            
            busRoutineSummaryImage.topAnchor.constraint(equalTo: routeStackView.bottomAnchor, constant: 23),
            busRoutineSummaryImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 42),
            busRoutineSummaryImage.widthAnchor.constraint(equalToConstant: 12),
            busRoutineSummaryImage.heightAnchor.constraint(equalToConstant: 84),
            
            busNumImage.topAnchor.constraint(equalTo: busRoutineSummaryImage.topAnchor),
            busNumImage.leadingAnchor.constraint(equalTo: busRoutineSummaryImage.trailingAnchor, constant: 11),
            busNumImage.widthAnchor.constraint(equalToConstant: 18.21),
            busNumImage.heightAnchor.constraint(equalToConstant: 21.3),
            
            busNumberLabel.centerYAnchor.constraint(equalTo: busNumImage.centerYAnchor),
            busNumberLabel.leadingAnchor.constraint(equalTo: busNumImage.trailingAnchor, constant: 4.26),
            
            startBusStopNameLabel.centerYAnchor.constraint(equalTo: busNumImage.centerYAnchor),
            startBusStopNameLabel.leadingAnchor.constraint(equalTo: busNumberLabel.trailingAnchor, constant: 8),
            
            endBusStopNameLabel.bottomAnchor.constraint(equalTo: busRoutineSummaryImage.bottomAnchor, constant: -1),
            endBusStopNameLabel.leadingAnchor.constraint(equalTo: busArrivalInfoLabel.leadingAnchor),
            
            busArrivalInfoLabel.topAnchor.constraint(equalTo: busNumImage.bottomAnchor, constant: 10),
            busArrivalInfoLabel.leadingAnchor.constraint(equalTo: busNumImage.leadingAnchor),
        ])
        setupRouteView()
    }
    
    @objc private func addRoutineButtonTapped() {
        addRoutineButton.isSelected.toggle()
        if let routeId = routeId, let startStation = startStation, let endStation = endStation {
            delegate?.routeRecommendCell(self, didTapAddRoutineButton: addRoutineButton.isSelected, routeId: routeId, startStation: startStation, endStation: endStation)
        }
    }
    
    private func updateDottedLinePath(for view: UIView) {
        if let shapeLayer = view.layer.sublayers?.first as? CAShapeLayer {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: view.bounds.height))
            shapeLayer.path = path
        }
    }
    private func setupRouteView() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        
        routeStackView = UIStackView()
        routeStackView.axis = .horizontal
        routeStackView.alignment = .center
        routeStackView.distribution = .fill
        routeStackView.spacing = -10
        routeStackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(routeStackView)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 23.34),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30.5),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30.5),
            container.heightAnchor.constraint(equalToConstant: 24),
            
            routeStackView.topAnchor.constraint(equalTo: container.topAnchor),
            routeStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            routeStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            routeStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
    }
    
    private func setupRouteSegments(firstWalkTime: Int, busTime: Int, finalWalkTime: Int) {
        routeStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let totalDuration = firstWalkTime + busTime + finalWalkTime
        let overlapAmount: CGFloat = 10
        
        let wheelWalkIcon = createTransportIcon(named: "WheelWalk")
        let walkSegment1 = createRouteSegment(type: .walk, duration: firstWalkTime, totalDuration: totalDuration)
        let busIcon = createTransportIcon(named: "MapBus")
        let busSegment = createRouteSegment(type: .bus, duration: busTime, totalDuration: totalDuration)
        let walkSegment2 = createRouteSegment(type: .walk, duration: finalWalkTime, totalDuration: totalDuration)
        
        routeStackView.addArrangedSubview(wheelWalkIcon)
        routeStackView.addArrangedSubview(walkSegment1)
        routeStackView.addArrangedSubview(busIcon)
        routeStackView.addArrangedSubview(busSegment)
        routeStackView.addArrangedSubview(walkSegment2)
        
        wheelWalkIcon.setContentHuggingPriority(.required, for: .horizontal)
        busIcon.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            wheelWalkIcon.trailingAnchor.constraint(equalTo: walkSegment1.leadingAnchor, constant: overlapAmount),
            busIcon.trailingAnchor.constraint(equalTo: busSegment.leadingAnchor, constant: overlapAmount)
        ])
        
        let segments = [walkSegment1, busSegment, walkSegment2]
        let durations = [firstWalkTime, busTime, finalWalkTime]
        
        let logDurations = durations.map { log(Double($0) + 1) }
        let totalLogDuration = logDurations.reduce(0, +)
        
        for (index, segment) in segments.enumerated() {
            let logDuration = logDurations[index]
            let widthMultiplier = CGFloat(logDuration / totalLogDuration)
            
            let widthConstraint = segment.widthAnchor.constraint(greaterThanOrEqualTo: routeStackView.widthAnchor, multiplier: widthMultiplier)
            widthConstraint.priority = .defaultHigh
            widthConstraint.isActive = true
            
            segment.widthAnchor.constraint(greaterThanOrEqualToConstant: minSegmentWidth).isActive = true
        }
        
        walkSegment2.layer.zPosition = 1
        busSegment.layer.zPosition = 2
        walkSegment1.layer.zPosition = 3
        wheelWalkIcon.layer.zPosition = 4
        busIcon.layer.zPosition = 4
    }
    
    private func createRouteSegment(type: RouteSegmentType, duration: Int, totalDuration: Int) -> UIView {
        let segmentView = UIView()
        segmentView.translatesAutoresizingMaskIntoConstraints = false
        
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.layer.masksToBounds = true
        lineView.layer.cornerRadius = 7.83
        
        let durationLabel = UILabel()
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont.systemFont(ofSize: 9)
        durationLabel.text = "\(duration)분"
        durationLabel.textAlignment = .center
        durationLabel.adjustsFontSizeToFitWidth = true
        durationLabel.minimumScaleFactor = 0.5
        
        segmentView.addSubview(lineView)
        segmentView.addSubview(durationLabel)
        
        switch type {
        case .walk:
            lineView.backgroundColor = UIColor(red: 0.943, green: 0.943, blue: 0.943, alpha: 1)
            durationLabel.textColor = UIColor(red: 0.62, green: 0.62, blue: 0.62, alpha: 1)
        case .bus:
            lineView.backgroundColor = UIColor(red: 0.25, green: 0.475, blue: 1, alpha: 1)
            durationLabel.textColor = .white
        }
        
        NSLayoutConstraint.activate([
            segmentView.heightAnchor.constraint(equalToConstant: 24),
            
            lineView.heightAnchor.constraint(equalToConstant: 15.66),
            lineView.centerYAnchor.constraint(equalTo: segmentView.centerYAnchor),
            lineView.leadingAnchor.constraint(equalTo: segmentView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: segmentView.trailingAnchor),
            
            durationLabel.centerXAnchor.constraint(equalTo: lineView.centerXAnchor),
            durationLabel.centerYAnchor.constraint(equalTo: lineView.centerYAnchor),
            durationLabel.leadingAnchor.constraint(greaterThanOrEqualTo: lineView.leadingAnchor, constant: 2),
            durationLabel.trailingAnchor.constraint(lessThanOrEqualTo: lineView.trailingAnchor, constant: -2)
        ])
        
        segmentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        segmentView.tag = duration
        
        return segmentView
    }
    
    private func createTransportIcon(named: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: named))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        return imageView
    }
    
    private func updateTotalTime(_ time: Int) {
        let fullString = NSMutableAttributedString(string: "\(time)분")
        
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "NotoSansKR-Medium", size: 32) ?? UIFont.systemFont(ofSize: 32)
        ]
        fullString.addAttributes(numberAttributes, range: NSRange(location: 0, length: String(time).count))
        
        let unitAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "NotoSansKR-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        ]
        fullString.addAttributes(unitAttributes, range: NSRange(location: String(time).count, length: 1))
        
        timeLabel.attributedText = fullString
    }
    
    private func updateWheelWalkTime(_ time: Int) {
        wheelWalkTimeLabel.text = "휠워크 \(time)분"
    }
    
    private func updatebusArrivalInfoLabel(_ time: Int) {
        wheelWalkTimeLabel.text = "휠워크 \(time)분"
    }
    
    func updateBusNumber(_ number: Int) {
        busNumberLabel.text = "\(number)"
    }
    
    func updateBusStopNames(start: String, end: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        startBusStopNameLabel.attributedText = NSAttributedString(string: start, attributes: [.paragraphStyle: paragraphStyle])
        endBusStopNameLabel.attributedText = NSAttributedString(string: end, attributes: [.paragraphStyle: paragraphStyle])
    }
    
    func setContentVisible(_ isVisible: Bool) {
        self.alpha = isVisible ? 1.0 : 0.0
    }
    
    func updateRouteSegments(firstWalkTime: Int, busTime: Int, finalWalkTime: Int) {
        let subviews = routeStackView.arrangedSubviews
        if subviews.count >= 5,
           let walkSegment1 = subviews[1] as? UIView,
           let busSegment = subviews[3] as? UIView,
           let walkSegment2 = subviews[4] as? UIView {
            
            updateSegmentTime(segment: walkSegment1, time: firstWalkTime)
            updateSegmentTime(segment: busSegment, time: busTime)
            updateSegmentTime(segment: walkSegment2, time: finalWalkTime)
        } else {
            print("Unexpected routeStackView structure. Subview count: \(subviews.count)")
        }
    }
    
    private func updateSegmentTime(segment: UIView, time: Int) {
        if let durationLabel = segment.subviews.first(where: { $0 is UILabel }) as? UILabel {
            durationLabel.text = "\(time)분"
        }
    }
    func setupRouteInfo(totalTime: Int, wheelWalkTime: Int, firstWalkTime: Int, busTime: Int, finalWalkTime: Int, busNumber: Int, startBusStop: String, endBusStop: String) {
        updateTotalTime(totalTime)
        updateWheelWalkTime(wheelWalkTime)
        setupRouteSegments(firstWalkTime: firstWalkTime, busTime: busTime, finalWalkTime: finalWalkTime)
        updateBusNumber(busNumber)
        updateBusStopNames(start: startBusStop, end: endBusStop)
        setContentVisible(true)
    }
    
    func configure(userId: Int, totalTime: Int, wheelWalkTime: Int, firstWalkTime: Int, busTime: Int, finalWalkTime: Int, busNumber: Int, startBusStop: String, endBusStop: String, stationId: String, routeId: String) {
        updateTotalTime(totalTime)
        updateWheelWalkTime(wheelWalkTime)
        setupRouteSegments(firstWalkTime: firstWalkTime, busTime: busTime, finalWalkTime: finalWalkTime)
        updateBusNumber(busNumber)
        updateBusStopNames(start: startBusStop, end: endBusStop)
        fetchBusArrivalInfo(stationId: stationId, routeId: routeId)
        
        self.routeId = busNumber
        self.startStation = startBusStop
        self.endStation = endBusStop
        
        checkRoutineStatus(userId: userId, routeId: busNumber)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .white
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
    //Cell이 재사용될 때 Timer를 정리하기 위해
    override func prepareForReuse() {
        super.prepareForReuse()
        updateTimer?.invalidate()
        updateTimer = nil
        currentStationId = nil
        currentRouteId = nil
    }
    
    func checkRoutineStatus(userId: Int, routeId: Int) {
        let urlString = "http://ec2-3-34-193-237.ap-northeast-2.compute.amazonaws.com:8080/user/\(userId)/\(routeId)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Bool],
                   let isRegistered = json["register"] {
                    DispatchQueue.main.async {
                        self.addRoutineButton.isSelected = isRegistered
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    
    
    
    
    
}
