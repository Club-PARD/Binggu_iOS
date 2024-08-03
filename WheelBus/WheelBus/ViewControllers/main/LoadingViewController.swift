//
//  LoadingViewController.swift
//  WheelBus
//
//  Created by 유재혁 on 8/2/24.
//

import UIKit

class LoadingViewController: UIViewController {
    let busimage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = false // 뷰의 경계 벗어나도 괜찮게
        imageView.image = UIImage(named: "bus")
        return imageView
    }()
    
    var titlelabel : UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "WheelBUS"
        title.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        title.font = UIFont.nanumSquareNeo(.extraBold, size: 40)
        return title
    }()
    
    var secondtext: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let fullText = "여섯 바퀴가 함께라서 \n더 특별한 이동,"

        // NSMutableAttributedString으로 텍스트 설정
        let attributedText = NSMutableAttributedString(string: fullText)
       
        // "여섯 바퀴가 함께" 부분의 글꼴과 속성 설정//
        let boldFont = UIFont.nanumSquareNeo(.bold, size: 17)
        let regularFont = UIFont.nanumSquareNeo(.regular, size: 17)
               
        let boldRange = (fullText as NSString).range(of: "여섯 바퀴가 함께")
        let regularRange = (fullText as NSString).range(of: "라서 \n더 특별한 이동,")
       
        attributedText.addAttribute(.font, value: boldFont, range: boldRange)
        attributedText.addAttribute(.font, value: regularFont, range: regularRange)
       
        label.attributedText = attributedText
        label.textAlignment = .center
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.numberOfLines = 2
        return label
    }()
    
    func setfunc() {
        view.addSubview(busimage)
        view.addSubview(titlelabel)
        view.addSubview(secondtext)
        
        NSLayoutConstraint.activate([
            busimage.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.33),
            busimage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            busimage.heightAnchor.constraint(equalToConstant: 54),
            
            titlelabel.topAnchor.constraint(equalTo: busimage.bottomAnchor, constant: 27),
            titlelabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            secondtext.topAnchor.constraint(equalTo: busimage.bottomAnchor, constant: 82),
            secondtext.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0, green: 0.4780646563, blue: 0.9985368848, alpha: 1)
                
        setfunc()
        
        // 3초 후에 MainViewController로 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let mainVC = MainViewController()
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true, completion: nil)
        }
    }
}
