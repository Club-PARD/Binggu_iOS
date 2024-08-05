//
//  FrequentEditCell.swift
//  WheelBus
//
//  Created by 유재혁 on 8/4/24.
//
import UIKit

class FrequentEditCell: UICollectionViewCell {
    private let startStationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.nanumSquareNeo(.bold, size: 11)
        label.textColor = .black
        return label
    }()
    
    private let checkimage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit //
        imageView.clipsToBounds = false // 뷰의 경계 벗어나도 괜찮게
        imageView.image = UIImage(named: "uncheck")
        return imageView
    }()
    
    private let endStationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.nanumSquareNeo(.bold, size: 11)
        label.textColor = .black
        return label
    }()
    
    private let busNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.nanumSquareNeo(.extraBold, size: 12)
        label.textColor = .blue
        return label
    }()
    
    private let busimage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit //
        imageView.clipsToBounds = false // 뷰의 경계 벗어나도 괜찮게
        imageView.image = UIImage(named: "littlebus")
        return imageView
    }()
    
    let barimage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit //
        imageView.clipsToBounds = false // 뷰의 경계 벗어나도 괜찮게
        imageView.image = UIImage(named: "line")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        [startStationLabel, endStationLabel, busNumberLabel, busimage, barimage, checkimage].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            startStationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            startStationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 54),
            startStationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -29),
            
            endStationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -33),
            endStationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 54),
            endStationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -29),
            
            busNumberLabel.centerYAnchor.constraint(equalTo: busimage.centerYAnchor),
            busNumberLabel.leadingAnchor.constraint(equalTo: busimage.leadingAnchor, constant: 20),
            
            busimage.topAnchor.constraint(equalTo: startStationLabel.bottomAnchor, constant: 0),
            busimage.leadingAnchor.constraint(equalTo: startStationLabel.leadingAnchor),
            busimage.widthAnchor.constraint(equalToConstant: 12),
            
            barimage.topAnchor.constraint(equalTo: startStationLabel.topAnchor, constant: 1),
            barimage.bottomAnchor.constraint(equalTo: endStationLabel.bottomAnchor, constant: -3.5),
            barimage.trailingAnchor.constraint(equalTo: startStationLabel.leadingAnchor, constant: -14),
            
            checkimage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            checkimage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            checkimage.heightAnchor.constraint(equalToConstant: 21),
        ])
    }
    
    func configure(with route: FrequentRoute?) {
        if let route = route {
            startStationLabel.text = "\(route.startStation)"
            endStationLabel.text = "\(route.endStation)"
            busNumberLabel.text = route.busNumber
        }
    }
    func setSelected(_ isSelected: Bool) {
        super.isSelected = isSelected  // 이 줄을 추가합니다

        // 배경색 변경
        contentView.backgroundColor = isSelected ?
            UIColor(red: 0.98, green: 0.986, blue: 1, alpha: 1) :
            UIColor(red: 0.992, green: 0.992, blue: 0.992, alpha: 1)
        
        // 테두리 색상 변경
        contentView.layer.borderColor = isSelected ?
            UIColor(red: 0.848, green: 0.894, blue: 1, alpha: 1).cgColor :
            UIColor(red: 0.951, green: 0.953, blue: 0.957, alpha: 1).cgColor
        
        // 체크 이미지 변경
        checkimage.image = isSelected ?
            UIImage(named: "check") :
            UIImage(named: "uncheck")
        
        // 변경사항 즉시 적용
        contentView.setNeedsDisplay()
    }
}
