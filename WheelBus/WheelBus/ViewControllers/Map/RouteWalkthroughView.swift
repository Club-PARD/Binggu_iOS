import UIKit

class RouteWalkthroughView: UIScrollView {
    private let contentView = UIView()
    
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
        
        let fullString = NSMutableAttributedString(string: "25분")
        
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "NotoSansKR-Medium", size: 32) ?? UIFont.systemFont(ofSize: 32)
        ]
        fullString.addAttributes(numberAttributes, range: NSRange(location: 0, length: 2))
        
        let unitAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "NotoSansKR-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        ]
        fullString.addAttributes(unitAttributes, range: NSRange(location: 2, length: 1))
        
        label.attributedText = fullString
        
        return label
    }()
    
    private let wheelWalkTimeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "WheelWalkTime")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let wheelWalkTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "NanumSquareNeo-Bold", size: 12)
        label.text = "휠워크 13분"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let routeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let grayDottedLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red: 0.799, green: 0.804, blue: 0.828, alpha: 1).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [2, 2]
        
        view.layer.addSublayer(shapeLayer)
        
        return view
    }()
    
    private let addRoutineImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "AddRoutine")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let busRoutineSummaryImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "BusRoutineSummary")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let busNumImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "BusNum")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let busNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0, green: 0.3, blue: 1, alpha: 1)
        label.font = UIFont(name: "NanumSquareNeo-ExtraBold", size: 22)
        label.textAlignment = .center
        
        let paragraphStyle = NSMutableParagraphStyle()
        label.attributedText = NSAttributedString(string: "206", attributes: [.paragraphStyle: paragraphStyle])
        
        return label
    }()

    private let busStopNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        label.font = UIFont(name: "NanumSquareNeo-Bold", size: 18)
        
        let paragraphStyle = NSMutableParagraphStyle()
        label.attributedText = NSAttributedString(string: "스타벅스 포항양덕점...", attributes: [.paragraphStyle: paragraphStyle])
        
        return label
    }()

    private let secondGrayDottedLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red: 0.799, green: 0.804, blue: 0.828, alpha: 1).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [2, 2]
        
        view.layer.addSublayer(shapeLayer)
        
        return view
    }()
    
    private let finishImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Finish")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let destinationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        label.font = UIFont(name: "NotoSansKR-Medium", size: 18)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.04
        label.attributedText = NSAttributedString(string: "한동대학교 산학협력관", attributes: [.paragraphStyle: paragraphStyle])
        
        return label
    }()
    
    private let busArrivalInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1)
        label.font = UIFont(name: "NanumSquareNeo-Bold", size: 15)
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        label.attributedText = NSAttributedString(string: "도착 예정 정보없음", attributes: [
            .kern: -0.3,
            .paragraphStyle: paragraphStyle
        ])
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
        setupView()
    }
    
    private func setupScrollView() {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    private func setupView() {
        backgroundColor = .white
        
        contentView.addSubview(totalTimeLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(wheelWalkTimeImage)
        contentView.addSubview(wheelWalkTimeLabel)
        contentView.addSubview(routeStackView)
        contentView.addSubview(grayDottedLine)
        contentView.addSubview(addRoutineImage)
        contentView.addSubview(busRoutineSummaryImage)
        contentView.addSubview(busNumImage)
        contentView.addSubview(busNumberLabel)
        contentView.addSubview(busStopNameLabel)
        contentView.addSubview(secondGrayDottedLine)
        contentView.addSubview(finishImage)
        contentView.addSubview(destinationLabel)
        contentView.addSubview(busArrivalInfoLabel)
        
        NSLayoutConstraint.activate([
            totalTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            totalTimeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),
            
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            timeLabel.topAnchor.constraint(equalTo: totalTimeLabel.bottomAnchor, constant: 10.6),
            
            wheelWalkTimeImage.trailingAnchor.constraint(equalTo: wheelWalkTimeLabel.leadingAnchor, constant: -5.41),
            wheelWalkTimeImage.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            wheelWalkTimeImage.widthAnchor.constraint(equalToConstant: 19),
            wheelWalkTimeImage.heightAnchor.constraint(equalToConstant: 16),
            
            wheelWalkTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -36.19),
            wheelWalkTimeLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            wheelWalkTimeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 67),
            
            routeStackView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 23.34),
            routeStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30.5),
            routeStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.5),
            routeStackView.heightAnchor.constraint(equalToConstant: 24),
            
            grayDottedLine.topAnchor.constraint(equalTo: routeStackView.bottomAnchor, constant: 13.39),
            grayDottedLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 42),
            grayDottedLine.widthAnchor.constraint(equalToConstant: 1),
            grayDottedLine.heightAnchor.constraint(equalToConstant: 66),
            
            addRoutineImage.centerYAnchor.constraint(equalTo: grayDottedLine.centerYAnchor),
            addRoutineImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -31),
            addRoutineImage.widthAnchor.constraint(equalToConstant: 100),
            addRoutineImage.heightAnchor.constraint(equalToConstant: 34),
            
            busRoutineSummaryImage.topAnchor.constraint(equalTo: grayDottedLine.bottomAnchor, constant: 10),
            busRoutineSummaryImage.centerXAnchor.constraint(equalTo: grayDottedLine.centerXAnchor),
            busRoutineSummaryImage.widthAnchor.constraint(equalToConstant: 24),
            busRoutineSummaryImage.heightAnchor.constraint(equalToConstant: 171),

            busNumImage.topAnchor.constraint(equalTo: busRoutineSummaryImage.topAnchor),
            busNumImage.leadingAnchor.constraint(equalTo: busRoutineSummaryImage.trailingAnchor, constant: 11),
            busNumImage.widthAnchor.constraint(equalToConstant: 18.21),
            busNumImage.heightAnchor.constraint(equalToConstant: 21.3),

            busNumberLabel.centerYAnchor.constraint(equalTo: busNumImage.centerYAnchor),
            busNumberLabel.leadingAnchor.constraint(equalTo: busNumImage.trailingAnchor, constant: 4.26),

            busStopNameLabel.centerYAnchor.constraint(equalTo: busNumImage.centerYAnchor),
            busStopNameLabel.leadingAnchor.constraint(equalTo: busNumberLabel.trailingAnchor, constant: 8),
            
            secondGrayDottedLine.topAnchor.constraint(equalTo: busRoutineSummaryImage.bottomAnchor, constant: 10),
            secondGrayDottedLine.centerXAnchor.constraint(equalTo: grayDottedLine.centerXAnchor),
            secondGrayDottedLine.widthAnchor.constraint(equalToConstant: 1),
            secondGrayDottedLine.heightAnchor.constraint(equalToConstant: 49),
            
            finishImage.topAnchor.constraint(equalTo: secondGrayDottedLine.bottomAnchor, constant: 10),
            finishImage.centerXAnchor.constraint(equalTo: grayDottedLine.centerXAnchor),
            finishImage.widthAnchor.constraint(equalToConstant: 26),
            finishImage.heightAnchor.constraint(equalToConstant: 34),
            
            destinationLabel.centerYAnchor.constraint(equalTo: finishImage.centerYAnchor),
            destinationLabel.leadingAnchor.constraint(equalTo: finishImage.trailingAnchor, constant: 10),
            destinationLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            busArrivalInfoLabel.topAnchor.constraint(equalTo: busNumImage.bottomAnchor, constant: 13.7),
            busArrivalInfoLabel.leadingAnchor.constraint(equalTo: busNumImage.leadingAnchor),
            
            contentView.bottomAnchor.constraint(equalTo: finishImage.bottomAnchor, constant: 20)
        ])
        
        setupRouteView()
        
        updateDottedLinePath(for: grayDottedLine)
        updateDottedLinePath(for: secondGrayDottedLine)
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
        let walkDuration1 = 6
        let busDuration = 12
        let walkDuration2 = 7
        let totalDuration = walkDuration1 + busDuration + walkDuration2

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        let segmentStack = UIStackView()
        segmentStack.axis = .horizontal
        segmentStack.alignment = .center
        segmentStack.distribution = .fill
        segmentStack.spacing = -10
        segmentStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(segmentStack)

        let wheelWalkIcon = createTransportIcon(named: "WheelWalk")
        let walkSegment1 = createRouteSegment(type: .walk, duration: walkDuration1, totalDuration: totalDuration)
        let busIcon = createTransportIcon(named: "MapBus")
        let busSegment = createRouteSegment(type: .bus, duration: busDuration, totalDuration: totalDuration)
        let walkSegment2 = createRouteSegment(type: .walk, duration: walkDuration2, totalDuration: totalDuration)

        // 조정 가능: 아이콘과 세그먼트의 겹침 정도
        let overlapAmount: CGFloat = 10

        segmentStack.addArrangedSubview(wheelWalkIcon)
        segmentStack.addArrangedSubview(walkSegment1)
        segmentStack.addArrangedSubview(busIcon)
        segmentStack.addArrangedSubview(busSegment)
        segmentStack.addArrangedSubview(walkSegment2)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 23.34),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30.5),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30.5),
            container.heightAnchor.constraint(equalToConstant: 24),

            segmentStack.topAnchor.constraint(equalTo: container.topAnchor),
            segmentStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            segmentStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            segmentStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            // 아이콘과 세그먼트 겹침 설정
            wheelWalkIcon.trailingAnchor.constraint(equalTo: walkSegment1.leadingAnchor, constant: overlapAmount),
            busIcon.trailingAnchor.constraint(equalTo: busSegment.leadingAnchor, constant: overlapAmount)
        ])

        wheelWalkIcon.setContentHuggingPriority(.required, for: .horizontal)
        busIcon.setContentHuggingPriority(.required, for: .horizontal)

        let segments = [walkSegment1, busSegment, walkSegment2]
        for segment in segments {
            let duration = segment.tag
            let widthConstraint = segment.widthAnchor.constraint(equalTo: segmentStack.widthAnchor, multiplier: CGFloat(duration) / CGFloat(totalDuration))
            widthConstraint.priority = .defaultHigh
            widthConstraint.isActive = true
        }

        // zIndex 설정
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
            durationLabel.centerYAnchor.constraint(equalTo: lineView.centerYAnchor)
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
    
    func updateTotalTime(_ time: Int) {
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
    
    func updateWheelWalkTime(_ time: Int) {
        wheelWalkTimeLabel.text = "휠워크 \(time)분"
    }
    
    func updateBusNumber(_ number: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        busNumberLabel.attributedText = NSAttributedString(string: number, attributes: [.paragraphStyle: paragraphStyle])
    }

    func updateBusStopName(_ name: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        busStopNameLabel.attributedText = NSAttributedString(string: name, attributes: [.paragraphStyle: paragraphStyle])
    }
    
    func updateDestination(_ destination: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.04
        destinationLabel.attributedText = NSAttributedString(string: destination, attributes: [.paragraphStyle: paragraphStyle])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDottedLinePath(for: grayDottedLine)
        updateDottedLinePath(for: secondGrayDottedLine)
    }
}

enum RouteSegmentType {
    case walk
    case bus
}
