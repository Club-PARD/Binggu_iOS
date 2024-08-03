//
//  FrequentRouteCell.swift
//  WheelBus
//
//  Created by 유재혁 on 8/3/24.
// 즐겨찾기

import UIKit

class FrequentRouteCell: UICollectionViewCell {
    private let startStationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.nanumSquareNeo(.regular, size: 14)
        label.textColor = .black
        return label
    }()
    
    private let endStationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.nanumSquareNeo(.regular, size: 14)
        label.textColor = .black
        return label
    }()
    
    private let busNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.nanumSquareNeo(.bold, size: 16)
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
        
        [startStationLabel, endStationLabel, busNumberLabel, busimage, barimage].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            startStationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            startStationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 54),
            startStationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -29),
            
            endStationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -39),
            endStationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 54),
            endStationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -29),
            
            busNumberLabel.centerYAnchor.constraint(equalTo: busimage.centerYAnchor),
            busNumberLabel.leadingAnchor.constraint(equalTo: busimage.leadingAnchor, constant: 20),
            
            busimage.topAnchor.constraint(equalTo: startStationLabel.bottomAnchor, constant: 7),
            busimage.leadingAnchor.constraint(equalTo: startStationLabel.leadingAnchor),
            busimage.widthAnchor.constraint(equalToConstant: 15),
            
            barimage.topAnchor.constraint(equalTo: startStationLabel.topAnchor, constant: 1),
            barimage.bottomAnchor.constraint(equalTo: endStationLabel.bottomAnchor, constant: -3.5),
            barimage.trailingAnchor.constraint(equalTo: startStationLabel.leadingAnchor, constant: -14)
        ])
    }
    
    func configure(with route: FrequentRoute?) {
        if let route = route {
            startStationLabel.text = "\(route.startStation)"
            endStationLabel.text = "\(route.endStation)"
            busNumberLabel.text = route.busNumber
        }
    }
}
