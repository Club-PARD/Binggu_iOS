//
//  EditViewController.swift
//  WheelBus
//
//  Created by 유재혁 on 8/3/24.
//

import UIKit

class EditViewController: UIViewController {
    
    let backButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.background.backgroundColor = .clear

        if let image = UIImage(named: "back") {
            config.image = image
        }

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit  // 이미지 비율 유지 설정
        button.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        return button
    }()
    
    let editlabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "자주 가는 길 편집"
            label.font = UIFont.nanumSquareNeo(.extraBold, size: 24)
            label.textColor = .black
            return label
    }()

    @objc func dismissViewController() {
        self.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setui()
    }
    
    func setui() {
        view.addSubview(backButton)
        view.addSubview(editlabel)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            
            editlabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            editlabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
