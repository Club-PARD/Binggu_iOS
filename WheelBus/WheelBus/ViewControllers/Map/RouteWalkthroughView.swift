import UIKit

class RouteWalkthroughView: UIView {
    
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
        
        // "25" 부분의 속성 설정
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "NotoSansKR-Medium", size: 32) ?? UIFont.systemFont(ofSize: 32)
        ]
        fullString.addAttributes(numberAttributes, range: NSRange(location: 0, length: 2))
        
        // "분" 부분의 속성 설정
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        
        addSubview(totalTimeLabel)
        addSubview(timeLabel)
        addSubview(wheelWalkTimeImage)
        addSubview(wheelWalkTimeLabel)
        
        NSLayoutConstraint.activate([
            totalTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            totalTimeLabel.topAnchor.constraint(equalTo: topAnchor),
            
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            timeLabel.topAnchor.constraint(equalTo: totalTimeLabel.bottomAnchor, constant: 10.6),
            
            wheelWalkTimeImage.trailingAnchor.constraint(equalTo: wheelWalkTimeLabel.leadingAnchor, constant: -5.41),
            wheelWalkTimeImage.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            wheelWalkTimeImage.widthAnchor.constraint(equalToConstant: 19),
            wheelWalkTimeImage.heightAnchor.constraint(equalToConstant: 16),
            
            wheelWalkTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -36.19),
            wheelWalkTimeLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            wheelWalkTimeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 67),
        ])
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
}
