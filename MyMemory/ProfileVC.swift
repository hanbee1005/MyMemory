//
//  ProfileVC.swift
//  MyMemory
//
//  Created by 손한비 on 2021/08/20.
//

import UIKit
import Alamofire
import LocalAuthentication

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // API 호출 상태값을 관리할 변수
    var isCalling = false
    
    let profileImage = UIImageView() // 프로필 사진 이미지
    let tv = UITableView()  // 프로필 목록
    
    let uinfo = UserInfoManager()  // 개인 정보 관리 매니저
    
    override func viewDidLoad() {
        self.navigationItem.title = "프로필"
        
        // 뒤로가기 버튼 처리
        let backBtn = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // 배경 이미지 설정
        let bg = UIImage(named: "profile-bg")
        let bgImage = UIImageView(image: bg)
        
        bgImage.frame.size = CGSize(width: bgImage.frame.size.width, height: bgImage.frame.size.height)
        bgImage.center = CGPoint(x: self.view.frame.width / 2, y: 40)
        
        bgImage.layer.cornerRadius = bgImage.frame.size.width / 2
        bgImage.layer.borderWidth = 0
        bgImage.layer.masksToBounds = true
        
        self.view.addSubview(bgImage)
        
        // 프로필 사진에 들어갈 기본 이미지
        let image = self.uinfo.profile
        
        // 프로필 이미지 처리
        self.profileImage.image = image
        self.profileImage.frame.size = CGSize(width: 100, height: 100)
        self.profileImage.center = CGPoint(x: self.view.frame.width / 2, y: 270)
        
        // 프로필 이미지 둥글게 만들기
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true
        
        // 루트 뷰에 추가
        self.view.addSubview(self.profileImage)
        
        // 테이블 뷰
        self.tv.frame = CGRect(x: 0, y: self.profileImage.frame.origin.y + self.profileImage.frame.size.height + 20, width: self.view.frame.width, height: 100)
        self.tv.delegate = self
        self.tv.dataSource = self
        
        self.view.addSubview(self.tv)
        
        // 내비게이션 바 숨김 처리
        self.navigationController?.navigationBar.isHidden = true
        
        // 최초 화면 로딩 시 로그인 상태에 따라 적절히 로그인/로그아웃 버튼을 출력한다.
        self.drawBtn()
        
        // 프로필 이미지에 탭 제스쳐 등록
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImage.addGestureRecognizer(tap)
        self.profileImage.isUserInteractionEnabled = true
    }
    
    @IBAction func backProfileVC(_ segue: UIStoryboardSegue) {
        // 단지 프로필 화면으로 되돌아오기 위한 표식 역할만 할 뿐이며
        // 아무 내용도 작성하지 않음
    }
    
    @objc func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func doLogin(_ sender: Any) {
        if self.isCalling {
            self.alert("응답을 기다리는 중입니다. \n잠시만 기다려 주세요.")
            return
        } else {
            self.isCalling = true
        }
        
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
        loginAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.isCalling = false
        })
        
        loginAlert.addAction(UIAlertAction(title: "Login", style: .destructive) { (_) in
            // 네트워크 인디케이터 실행
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let account = loginAlert.textFields?[0].text ?? ""  // 첫번째 필드 : 계정
            let passwd = loginAlert.textFields?[1].text ?? "" // 두번째 필드 : 비밀번호
            
//            if self.uinfo.login(account: account, passwd: passwd) {
//                self.tv.reloadData()  // 테이블 뷰를 갱신한다.
//                self.profileImage.image = self.uinfo.profile  // 이미지 프로필을 갱신한다.
//                self.drawBtn()  // 로그인 상태에 따라 적절히 로그인/로그아웃 버튼을 출력한다.
//            } else {
//                let msg = "로그인에 실패하였습니다."
//                let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                self.present(alert, animated: false, completion: nil)
//            }
            
            // 비동기 방식으로 변경
            self.uinfo.login(account: account, passwd: passwd, success: {
                // 네트워크 인디케이터 종료
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isCalling = false
                
                self.tv.reloadData()  // 테이블 뷰를 갱신한다.
                self.profileImage.image = self.uinfo.profile  // 이미지 프로필을 갱신한다.
                self.drawBtn()
            }, fail: { msg in
                // 네트워크 인디케이터 종료
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.isCalling = false
                
                self.alert(msg)
            })
        })
        
        self.present(loginAlert, animated: false, completion: nil)
    }
    
    @objc func doLogout(_ sender: Any) {
        let msg = "로그아웃하시겠습니까?"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { (_) in
            // 네트워크 인디케이터 실행
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
//            if self.uinfo.logout() {
//                self.tv.reloadData()  // 테이블 뷰를 갱신한다.
//                self.profileImage.image = self.uinfo.profile  // 이미지 프로필을 갱신한다.
//                self.drawBtn()  // 로그인 상태에 따라 적절히 로그인/로그아웃 버튼을 출력한다.
//            }
            self.uinfo.logout() {
                // Logout API 호출과 logout() 실행이 끝났을 떄 네트워크 인디케이터도 중지
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.tv.reloadData()
                self.profileImage.image = self.uinfo.profile
                self.drawBtn()
            }
        })
        
        self.present(alert, animated: false, completion: nil)
    }
    
    // 프로필 사진의 소스 타입을 선택하는 액션 메소드
    @objc func profile(_ sender: UIButton) {
        // 로그인 되어 있지 않을 경우에는 프로필 이미지 등록을 막고 대신 로그인 창을 띄워준다.
        guard self.uinfo.account != nil else {
            self.doLogin(self)
            return
        }
        
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택하세요.", preferredStyle: .actionSheet)
        
        // 카메라를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
                self.imagePicker(.camera)
            })
        }
        
        // 저장된 앨범을 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default) { (_) in
                self.imagePicker(.savedPhotosAlbum)
            })
        }
        
        // 포토 라이브러리를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) { (_) in
                self.imagePicker(.photoLibrary)
            })
        }
        
        // 취소 버튼 추가
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        // 액션 시트 창 실행
        self.present(alert, animated: true, completion: nil)
    }
    
    func drawBtn() {
        // 버튼을 감쌀 뷰를 정의한다.
        let v = UIView()
        v.frame.size.width = self.view.frame.width
        v.frame.size.height = 40
        v.frame.origin.x = 0
        v.frame.origin.y = self.tv.frame.origin.y + self.tv.frame.height
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        
        self.view.addSubview(v)
        
        // 버튼을 정의한다.
        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        btn.center.x = v.frame.size.width / 2
        btn.center.y = v.frame.size.height / 2
        
        // 로그인 상태일 때는 로그아웃 버튼을, 로그아웃 상태일 때는 로그인 버튼을 만들어준다.
        if self.uinfo.isLogin == true {
            btn.setTitle("로그아웃", for: .normal)
            btn.addTarget(self, action: #selector(doLogout(_:)), for: .touchUpInside)
        } else {
            btn.setTitle("로그인", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        
        v.addSubview(btn)
    }
    
    func imagePicker(_ source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    // MARK - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
        
        switch indexPath.row {
            case 0:
                cell.textLabel?.text = "이름"
                cell.detailTextLabel?.text = self.uinfo.name ?? "Login Please"
            case 1:
                cell.textLabel?.text = "계정"
                cell.detailTextLabel?.text = self.uinfo.account ?? "Login Please"
            default:
                ()
        }
        
        return cell
    }
    
    // MARK - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.uinfo.isLogin == false {
            // 로그인 되어 있지 않다면 로그인 창을 띄워 준다.
            self.doLogin(self.tv)
        }
    }
    
    // 이미지를 선택하면 이 메소드가 자동으로 실행된다.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 네트워크 인디케이터 실행
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.uinfo.newProfile(img, success: {
                // 네트워크 인디케이터 종료
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.profileImage.image = img
            }, fail: { msg in
                // 네트워크 인디케이터 종료
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.alert(msg)
            })
        }
        
        // 이 구문을 누락하면 이미지 피커 컨트롤러 창은 닫히지 않는다.
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProfileVC {
    // 토큰 인증 메소드
    func tokenValidate() {
        // 0. 응답 캐시를 사용하지 않도록
        URLCache.shared.removeAllCachedResponses()
        
        // 1. 키 체인에 액세스 토큰이 없을 경우 유효성 검증을 진행하지 않음
        let tk = TokenUtils()
        guard let header = tk.getAuthorizationHeader() else {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true  // 로딩 시작
        
        // 2. tokenValidate API를 호출한다.
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        validate.responseJSON { res in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false  // 로딩 중지
            
            switch res.result {
            case .success(let res):
                print(res)  // 2-1. 응답 결과를 확인하기 위해 메시지 본문 전체를 출력
                guard let jsonObject = res as? NSDictionary else {
                    self.alert("잘못된 응답입니다.")
                    return
                }
                
                // 3. 응답 결과 처리
                let resultCode = jsonObject["result_code"] as! Int
                if resultCode != 0 {  // 3-1. 응답 결과가 실패일 때, 즉 토큰이 만료되었을 때
                    // 로컬 인증 실행
                    self.touchID()
                }
            case .failure(let errer):
                self.alert(errer.localizedDescription)
            }
        }
    }
    
    // 터치 아이디 메소드
    func touchID() {
        
    }
    
    // 토큰 갱신 메소드
    func refresh() {
        
    }
}
