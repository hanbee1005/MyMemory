//
//  Utils.swift
//  MyMemory
//
//  Created by 손한비 on 2021/08/22.
//

import Security
import Alamofire

class TokenUtils {
    
}

extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: .main)
    }
    
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
    
    func alert(_ message: String, completion: (() -> Void)? = nil) {
        // 메인 스레드에서 실행되도록
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
                completion?()  // completion 매개변수 값이 nil이 아닐 때만 실행
            }
            
            alert.addAction(okAction)
            self.present(alert, animated: false, completion: nil)
        }
    }
}
