//
//  AddressTableViewCell.swift
//  WheelBus
//
//  Created by 유재혁 on 8/3/24.
//

import UIKit
import MapKit

class AddressTableViewCell: UITableViewCell {
    static let identifier = "AddressTableViewCell"
    
    private let magnifyingGlassImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let buildingNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.nanumSquareNeo(.bold, size: 18)
        label.textColor =  #colorLiteral(red: 0.3803921342, green: 0.3803921342, blue: 0.3803921342, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.nanumSquareNeo(.bold, size: 14)
        label.textColor =  #colorLiteral(red: 0.7803922296, green: 0.7803922296, blue: 0.7803922296, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(magnifyingGlassImageView)
        contentView.addSubview(buildingNameLabel)
        contentView.addSubview(addressLabel)
        
        NSLayoutConstraint.activate([
            magnifyingGlassImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            magnifyingGlassImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            magnifyingGlassImageView.widthAnchor.constraint(equalToConstant: 24),
            magnifyingGlassImageView.heightAnchor.constraint(equalToConstant: 24),
            
            buildingNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 53),
            buildingNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            buildingNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -45),
            
            addressLabel.leadingAnchor.constraint(equalTo: buildingNameLabel.leadingAnchor),
            addressLabel.topAnchor.constraint(equalTo: buildingNameLabel.bottomAnchor, constant: 10),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -45),
            addressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -23)
        ])
    }
    
    func configure(with result: MKLocalSearchCompletion) {
           buildingNameLabel.text = result.title
           addressLabel.text = removeCountryAndPostalCode(from: result.subtitle)
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
}
