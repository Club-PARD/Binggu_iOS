//
//  EditViewController.swift
//  WheelBus
//
//  Created by 유재혁 on 8/3/24.
//

import UIKit

protocol EditViewControllerDelegate: AnyObject {
    func fetchFrequentRoutes()
}

class EditViewController: UIViewController {
    weak var delegate: EditViewControllerDelegate?
    var frequentRoutes: [FrequentRoute] = []    //즐겨찾기 값들
    var userId: Int64?  //uid 받을 변수
    var selectedIndexPaths: Set<IndexPath> = [] //셀 선택하고 삭제하기 위해서
    var isAllSelected = false   //전체선택 하기 위해서
    
    private var deleteButtonLabelTrailingConstraint: NSLayoutConstraint?
    
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
    
    private lazy var allselectbutton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "uncheck")
        config.imagePadding = 0
        config.contentInsets = .zero
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false //이미지 크기도 수정하기 위해서
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(allselectbuttonTapped), for: .touchUpInside)
        return button
    }()
    
    let allLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "전체선택"
        label.font = UIFont.nanumSquareNeo(.bold, size: 15)
        label.textColor = .black
        return label
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
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0.837211132, green: 0.8480320573, blue: 0.8766182065, alpha: 1)
        button.isEnabled = false
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var deleteButtonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "선택 삭제"
        label.font = UIFont.nanumSquareNeo(.bold, size: 25)
        label.textColor = .white
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.nanumSquareNeo(.bold, size: 25)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    // 즐겨찾기 등록된 값 없을 때 나타나는 곳
    let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.backgroundColor = .white
        return view
    }()
    
    let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "등록된 길이 없어요."
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
        imageView.image = UIImage(named: "editempty")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    @objc private func allselectbuttonTapped() {
        isAllSelected.toggle()
        let imageName = isAllSelected ? "check" : "uncheck"
        allselectbutton.configuration?.image = UIImage(named: imageName)
        
        selectAllCells(isAllSelected)
        updateDeleteButtonState()
    }
    
    @objc private func deleteButtonTapped() {
        deleteSelectedRoutes()
        allselectbutton.configuration?.image = UIImage(named: "uncheck")
        
    }
    
    
    //
    //    if selectedIndexPaths.contains(indexPath) {
    //        selectedIndexPaths.remove(indexPath)
    //    } else {
    //        selectedIndexPaths.insert(indexPath)
    //    }
    //
    //    if let cell = collectionView.cellForItem(at: indexPath) as? FrequentEditCell {
    //        cell.setSelected(selectedIndexPaths.contains(indexPath))
    //    }
    //
    
    
    // 전체삭제 선택
    private func selectAllCells(_ isSelected: Bool) {
        for i in 0..<frequentRoutes.count {
            let indexPath = IndexPath(item: i, section: 0)
            if isSelected {
                selectedIndexPaths.insert(indexPath)
            } else {
                selectedIndexPaths.remove(indexPath)
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? FrequentEditCell {
                cell.setSelected(isSelected)
            }
        }
        // collectionView.reloadData() 대신 개별 셀 업데이트
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as? FrequentEditCell {
                cell.setSelected(selectedIndexPaths.contains(indexPath))
            }
        }
    }
    
    // 셀 누르면 선택삭제 몇개 했나 업데이트 해주는거
    private func updateDeleteButtonState() {
        let count = selectedIndexPaths.count
        if count > 0 {
            countLabel.animateTextChange(to: "\(count)")
            deleteButton.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0.4745098039, blue: 1, alpha: 1)
            deleteButton.isEnabled = true
            deleteButtonLabelTrailingConstraint?.constant = 10
        } else {
            countLabel.animateTextChange(to: "")
            deleteButton.backgroundColor = #colorLiteral(red: 0.837211132, green: 0.8480320573, blue: 0.8766182065, alpha: 1)
            deleteButton.isEnabled = false
            deleteButtonLabelTrailingConstraint?.constant = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.deleteButton.layoutIfNeeded()
        }
    }
    
    private func deleteSelectedRoutes() {
        let selectedRoutes = selectedIndexPaths.sorted(by: { $0.item > $1.item }).map { frequentRoutes[$0.item] }
        
        for route in selectedRoutes {
            deleteRoute(busNumber: route.busNumber)
            
        }
    }
    
    private func deleteRoute(busNumber: String) {
        guard let userId = userId else {
            print("User ID is not available")
            return
        }
        
        let urlString = "http://ec2-3-34-193-237.ap-northeast-2.compute.amazonaws.com:8080/user/\(userId)/\(busNumber)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error deleting route: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    if let index = self.frequentRoutes.firstIndex(where: { $0.busNumber == busNumber }) {
                        self.frequentRoutes.remove(at: index)
                    }
                    self.selectedIndexPaths.removeAll()
                    self.updateDeleteButtonState()
                    self.collectionView.reloadData()
                    self.updateEmptyState()
                }
            } else {
                print("Failed to delete route")
            }
        }.resume()
    }
    
    @objc func dismissViewController() {
        delegate?.fetchFrequentRoutes()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setui()
        fetchFrequentRoutes()
        updateEmptyState()
    }
    
    func setui() {
        view.addSubview(backButton)
        view.addSubview(editlabel)
        view.addSubview(collectionView)
        view.addSubview(line)
        view.addSubview(emptyStateView)
        view.addSubview(deleteButton)
        deleteButton.addSubview(deleteButtonLabel)
        deleteButton.addSubview(countLabel)
        view.addSubview(allselectbutton)
        view.addSubview(allLabel)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateLabel2)
        emptyStateView.addSubview(emptyStateImageView)
        
        deleteButtonLabelTrailingConstraint = deleteButtonLabel.centerXAnchor.constraint(equalTo: deleteButton.centerXAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 13),
            
            allselectbutton.bottomAnchor.constraint(equalTo: line.topAnchor, constant: -13),
            allselectbutton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            allselectbutton.heightAnchor.constraint(equalToConstant: 23),
            
            allLabel.centerYAnchor.constraint(equalTo: allselectbutton.centerYAnchor, constant: 1),
            allLabel.leadingAnchor.constraint(equalTo: allselectbutton.trailingAnchor, constant: 9),
            
            allselectbutton.imageView!.topAnchor.constraint(equalTo: allselectbutton.topAnchor),
            allselectbutton.imageView!.bottomAnchor.constraint(equalTo: allselectbutton.bottomAnchor),
            allselectbutton.imageView!.leadingAnchor.constraint(equalTo: allselectbutton.leadingAnchor),
            allselectbutton.imageView!.trailingAnchor.constraint(equalTo: allselectbutton.trailingAnchor),
            
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
            
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 114),
            
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -386.17),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 19),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            emptyStateLabel2.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 10),
            emptyStateLabel2.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 84),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 77),
            emptyStateImageView.topAnchor.constraint(equalTo: editlabel.bottomAnchor, constant: 220),
            
            deleteButtonLabel.topAnchor.constraint(equalTo: deleteButton.topAnchor, constant: 19),
            deleteButtonLabelTrailingConstraint!,

            countLabel.centerYAnchor.constraint(equalTo: deleteButtonLabel.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: deleteButtonLabel.leadingAnchor, constant: -5),
            countLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func fetchFrequentRoutes() {
        guard let userId = userId else {
            print("User ID is not available")
            return
        }
        
        let urlString = "http://ec2-3-34-193-237.ap-northeast-2.compute.amazonaws.com:8080/user/\(userId)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let routes = json["routes"] as? [String: [String: [String]]] {
                    var newRoutes: [FrequentRoute] = []
                    
                    for (busNumber, routeInfo) in routes {
                        if let route = routeInfo["route"],
                           route.count >= 2 {
                            let startStation = route[0]
                            let endStation = route[1]
                            let frequentRoute = FrequentRoute(startStation: startStation, endStation: endStation, busNumber: busNumber)
                            newRoutes.append(frequentRoute)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.frequentRoutes = newRoutes
                        self.updateEmptyState()
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    func updateEmptyState() {
        emptyStateView.isHidden = !frequentRoutes.isEmpty
        collectionView.isHidden = frequentRoutes.isEmpty
    }
}

extension EditViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frequentRoutes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrequentEditCell", for: indexPath) as! FrequentEditCell
        cell.configure(with: frequentRoutes[indexPath.item])
        
        // 여기에 셀의 선택 상태를 설정합니다
        cell.setSelected(selectedIndexPaths.contains(indexPath))
        
        // Cell 디자인 수정
        cell.contentView.backgroundColor = UIColor(red: 0.992, green: 0.992, blue: 0.992, alpha: 1)
        cell.contentView.layer.cornerRadius = 8 // 모서리 둥글게
        cell.contentView.layer.borderWidth = 2 // 테두리 굵기
        cell.contentView.layer.borderColor = UIColor(red: 0.951, green: 0.953, blue: 0.957, alpha: 1).cgColor
        cell.contentView.layer.masksToBounds = true // 내용이 셀의 경계를 넘지 않도록 설정
        
        cell.layer.masksToBounds = true // cell 자체에도 설정
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.remove(indexPath)
        } else {
            selectedIndexPaths.insert(indexPath)
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? FrequentEditCell {
            cell.setSelected(selectedIndexPaths.contains(indexPath))
            print("갸갸갸갸갸갸\(indexPath)")
        }
        
        updateDeleteButtonState()
        
        // 모든 셀이 선택되었는지 확인
        isAllSelected = selectedIndexPaths.count == frequentRoutes.count
        allselectbutton.configuration?.image = UIImage(named: isAllSelected ? "check" : "uncheck")
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

extension UILabel {
    func animateTextChange(to newText: String, duration: TimeInterval = 0.3) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.text = newText
        }, completion: nil)
    }
}
