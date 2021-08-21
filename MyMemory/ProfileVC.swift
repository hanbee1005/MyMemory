//
//  ProfileVC.swift
//  MyMemory
//
//  Created by 손한비 on 2021/08/20.
//

import UIKit

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let profileImage = UIImageView() // 프로필 사진 이미지
    let tv = UITableView()  // 프로필 목록
    
    let uinfo = UserInfoManager()  // 개인 정보 관리 매니저
    
    override func viewDidLoad() {
        self.navigationItem.title = "프로필"
        
        // 뒤로가기 버튼 처리
        let backBtn = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
    }
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func doLogin(_ sender: Any) {
        let loginAlert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
        
        // 알림창에 들어갈 입력폼 추가
        loginAlert.addTextField() { (tf) in
            tf.placeholder = "Your Account"
        }
        
        loginAlert.addTextField() { (tf) in
            tf.placeholder = "Password"
            tf.isSecureTextEntry = true
        }
        
        // 알림창 버튼 추가
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive) { (_) in
            let account = loginAlert.textFields?[0].text ?? ""  // 첫번째 필드 : 계정
            let passwd = loginAlert.textFields?[1].text ?? "" // 두번째 필드 : 비밀번호
            
            if self.uinfo.login(account: account, passwd: passwd) {
                // 로그인 성공 시 처리할 내용
            } else {
                let msg = "로그인에 실패하였습니다."
                let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: false, completion: nil)
            }
        })
        
        self.present(loginAlert, animated: false, completion: nil)
    }
    
    @objc func logout(_ sender: Any) {
        let msg = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { (_) in
            if self.uinfo.logout() {
                // 로그아웃 시 처리할 내용
            }
        })
        
        self.present(alert, animated: false, completion: nil)
    }
    
    // MARK - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        // 여기에 셀 구현 내용이 들어갈 예정
        
        return cell
    }
}
