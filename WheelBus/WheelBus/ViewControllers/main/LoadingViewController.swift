//
//  LoadingViewController.swift
//  WheelBus
//
//  Created by 유재혁 on 8/2/24.
//

import UIKit

class LoadingViewController: UIViewController {
    var userId: Int64?
    private var isCalculationCompleted = false
    private var isTimerExpired = false
    
    func fetchUserId() {
           guard let url = URL(string: "http://ec2-3-34-193-237.ap-northeast-2.compute.amazonaws.com:8080/user") else {
               print("Invalid URL")
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.addValue("*/*", forHTTPHeaderField: "accept")

           // POST 요청이므로 body 데이터가 필요하다면 설정해줍니다.
           // request.httpBody = someData

           let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
               if let error = error {
                   print("Error: \(error.localizedDescription)")
                   return
               }

               guard let data = data else {
                   print("No data received")
                   return
               }

               do {
                   if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int64],
                      let id = json["id"] {
                       DispatchQueue.main.async {
                           self?.userId = id
                           print("User ID: \(id)")
                           // UserDefaults에 저장
                           UserDefaults.standard.set(id, forKey: "userId")
                           // 여기에서 ID를 사용하여 추가 작업을 수행할 수 있습니다.
                       }
                   } else {
                       print("Invalid JSON structure")
                   }
               } catch {
                   print("JSON parsing error: \(error.localizedDescription)")
               }
           }

           task.resume()
       }
    
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
       
        // 캐시된 사용자 ID를 로드
        if let cachedUserId = UserDefaults.standard.value(forKey: "userId") as? Int64 {
            self.userId = cachedUserId
            print("Cached User ID: \(cachedUserId)")
        } else {
            fetchUserId() // 사용자 ID가 없으면 새로 생성
        }
        
        setfunc()
        print("\(String(describing: userId))")
        
        NotificationCenter.default.addObserver(self, selector: #selector(calculationsCompleted), name: Notification.Name("CalculationsCompleted"), object: nil)
        
        // 3초 후에 타이머 만료 처리
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isTimerExpired = true
            self.checkTransition()
        }
    }
    
    @objc private func calculationsCompleted() {
        isCalculationCompleted = true
        checkTransition()
    }
    
    private func checkTransition() {
        DispatchQueue.main.async {
            if self.isCalculationCompleted && self.isTimerExpired {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    let mainVC = MainViewController()
                    mainVC.userId = self.userId
                    window.rootViewController = mainVC
                    window.makeKeyAndVisible()
                } else {
                    print("Failed to get SceneDelegate or window")
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
