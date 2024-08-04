import UIKit

class RouteWalkthroughView: UIScrollView {
    private let contentView = UIView()
    private let minSegmentWidth: CGFloat = 40
    
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
        label.font = UIFont(name: "NotoSansKR-Medium", size: 32) ?? UIFont.systemFont(ofSize: 32)
        label.text = ""
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
        label.text = ""
        return label
    }()

    private let busStopNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        label.font = UIFont(name: "NanumSquareNeo-Bold", size: 18)
        label.text = ""
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
    
    func updateBusNumber(_ number: String) {
        busNumberLabel.text = number
    }

    func updateBusStopName(_ name: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        busStopNameLabel.attributedText = NSAttributedString(string: name, attributes: [.paragraphStyle: paragraphStyle])
    }
    
    func setContentVisible(_ isVisible: Bool) {
        self.alpha = isVisible ? 1.0 : 0.0
    }
    
    func updateDestination(_ destination: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.04
        destinationLabel.attributedText = NSAttributedString(string: destination, attributes: [.paragraphStyle: paragraphStyle])
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
    
    func setupRouteInfo(totalTime: Int, wheelWalkTime: Int, firstWalkTime: Int, busTime: Int, finalWalkTime: Int, busNumber: String) {
        updateTotalTime(totalTime)
        updateWheelWalkTime(wheelWalkTime)
        setupRouteSegments(firstWalkTime: firstWalkTime, busTime: busTime, finalWalkTime: finalWalkTime)
        updateBusNumber(busNumber)
        setContentVisible(true)
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
