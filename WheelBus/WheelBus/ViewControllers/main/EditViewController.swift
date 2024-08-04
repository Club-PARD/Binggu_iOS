//
//  EditViewController.swift
//  WheelBus
//
//  Created by 유재혁 on 8/3/24.
//

import UIKit

class EditViewController: UIViewController {
    var frequentRoutes: [FrequentRoute] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.register(FrequentEditCell.self, forCellWithReuseIdentifier: "FrequentEditCell")
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    var line: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(red: 0.929, green: 0.929, blue: 0.929, alpha: 1)
        return line
    }()
    
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
        fetchFrequentRoutes()
    }
    
    func setui() {
        view.addSubview(backButton)
        view.addSubview(editlabel)
        view.addSubview(collectionView)
        view.addSubview(line)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            
            editlabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            editlabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 170),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -133),
            
            line.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            line.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
        ])
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
        
        frequentRoutes = newRoutes
        collectionView.reloadData()
    }
}

extension EditViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frequentRoutes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrequentEditCell", for: indexPath) as! FrequentEditCell
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
        let spacing: CGFloat = 9 // 셀 사이의 간격
        let availableWidth = collectionView.bounds.width
        let cellWidth = (availableWidth - spacing) / 2 // 2개의 셀과 1개의 간격을 고려한 너비 계산
        return CGSize(width: floor(cellWidth), height: 128) // floor를 사용하여 정수 너비 보장
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9 // 가로 간격
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7 // 세로 간격
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 19, right: 0)
    }
}
