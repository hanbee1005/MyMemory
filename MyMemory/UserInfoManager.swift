//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by 손한비 on 2021/08/20.
//

import UIKit
import Alamofire

struct UserInfoKey {
    // 저장에 사용할 키
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL"
}

// 계정 및 사용자 정보를 저장 관리하는 클래스
class UserInfoManager {
    // 연산 프로퍼티 loginId 정의
    var loginId: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }
    
    // 연산 프로퍼티 account 정의
    var account: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }
    
    // 연산 프로퍼티 name 정의
    var name: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }
    
    // 연산 프로퍼티 profile 정의
    var profile: UIImage? {
        get {
            let ud = UserDefaults.standard
            if let _profile = ud.data(forKey: UserInfoKey.profile) {
                return UIImage(data: _profile)
            } else {
                return UIImage(named: "account.jpg")  // 이미지가 없다면 기본 이미지로
            }
        }
        set(v) {
            if v != nil {
                let ud = UserDefaults.standard
                ud.set(v!.pngData(), forKey: UserInfoKey.profile)
                ud.synchronize()
            }
        }
    }
    
    var isLogin: Bool {
        // 로그인 아이디가 0이거나 계정이 비어 있으면
        if self.loginId == 0 || self.account == nil {
            return false
        } else {
            return true
        }
    }
    
//    func login(account: String, passwd: String) -> Bool {
//        // 이 부분은 나중에 서버와 연동되는 코드로 대체될 예정입니다.
//        if account.isEqual("sqlpro@naver.com") && passwd.isEqual("1234") {
//            let ud = UserDefaults.standard
//            ud.set(100, forKey: UserInfoKey.loginId)
//            ud.set(account, forKey: UserInfoKey.account)
//            ud.set("재은씨", forKey: UserInfoKey.name)
//            ud.synchronize()
//            return true
//        } else {
//            return false
//        }
//    }
    
    func login(account: String, passwd: String, success: (() -> Void)? = nil, fail: ((String) -> Void)? = nil) {
        // 1. URL과 전송할 값 준비
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = [
            "account": account,
            "passwd": passwd
        ]
        
        // 2. API 호출
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        // 3. API 호출 결과 처리
        call.responseJSON { res in
            switch res.result {
            case .success(let res):
                // 3-1. JSON 형식으로 응답했는지 확인
                guard let jsonObject = res as? NSDictionary else {
                    fail?("잘못된 응답 형식입니다: \(res)")
                    return
                }
                
                // 3-2. 응답 코드 확인. 0이면 성공
                let resultCode = jsonObject["result_code"] as! Int
                if resultCode == 0 {
                    // 3-3. user_info 이하 항목을 딕셔너리 형태로 추출하여 저장
                    let user = jsonObject["user_info"] as! NSDictionary
                    
                    self.loginId = user["user_id"] as! Int
                    self.account = user["account"] as? String
                    self.name = user["name"] as? String
                    
                    // 3-4. user_info 항목 중에서 프로필 이미지 처리
                    if let path = user["profile_path"] as? String {
                        if let imageData = try? Data(contentsOf: URL(string: path)!) {
                            self.profile = UIImage(data: imageData)
                        }
                    }
                    
                    // 토큰 정보 추출
                    let accessToken = jsonObject["access_token"] as! String  // 액세스 토큰 추출
                    let refreshToken = jsonObject["refresh_token"] as! String  // 리프레시 토큰 추출
                    
                    // 토큰 정보 저장
                    let tk = TokenUtils()
                    tk.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
                    tk.save("kr.co.rubypaper.MyMemory", account: "refreshToken", value: refreshToken)
                    
                    // 3-5. 인자값으로 입력된 success 클로저 블록을 실행한다.
                    success?()
                } else {
                    let msg = (jsonObject["error_msg"] as? String) ?? "로그인이 실패하였습니다."
                    fail?(msg)
                }
            case .failure(let error):
                fail?(error.localizedDescription)
            }
        }
    }
    
//    func logout() -> Bool {
//        let ud = UserDefaults.standard
//        ud.removeObject(forKey: UserInfoKey.loginId)
//        ud.removeObject(forKey: UserInfoKey.account)
//        ud.removeObject(forKey: UserInfoKey.name)
//        ud.removeObject(forKey: UserInfoKey.profile)
//        ud.synchronize()
//        return true
//    }
    
    func logout(completion: (() -> Void)? = nil) {
        // 1. 호출 URL
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/logout"
        
        // 2. 인증 헤더 구현
        let tokenUtils = TokenUtils()
        let header = tokenUtils.getAuthorizationHeader()
        
        // 3. API 호출 및 응답 처리
        let call = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        call.responseJSON { _ in
            // 로컬 로그아웃
            self.localLogout()
            
            // 전달 받은 완료 클로저를 실행
            completion?()
        }
    }
    
    func localLogout() {
        // 기본 저장소에 저장된 값을 모두 삭제
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        
        // 키 체인에 저장된 값을 모두 삭제
        let tokenUtils = TokenUtils()
        tokenUtils.delete("kr.co.rubypaper.MyMemory", account: "refreshToken")
        tokenUtils.delete("kr.co.rubypaper.MyMemory", account: "accessToken")
    }
    
    func newProfile(_ profile: UIImage?, success: (() -> Void)? = nil, fail: ((String) -> Void)? = nil) {
        // API 호출 URL
        let url = "http://swiftapi.rubypaper.co.kr: 2029/userAccount/profile"
        
        // 인증 헤더
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()
        
        // 전송할 프로필 이미지
        let profileData = profile!.pngData()?.base64EncodedString()
        let param: Parameters = ["profile_image" : profileData!]
        
        // 이미지 전송
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        call.responseJSON { res in
            switch res.result {
            case .success(let res):
                guard let jsonObject = res as? NSDictionary else {
                    fail?("올바른 응답값이 아닙니다.")
                    return
                }
                
                // 응답 코드 확인. 0이면 성공
                let resultCode = jsonObject["result_code"] as! Int
                if resultCode == 0 {
                    self.profile = profile  // 이미지가 업로드되었다면 UserDefault에 저장된 이미지도 변경한다.
                    success?()
                } else {
                    let msg = (jsonObject["error_msg"] as? String) ?? "이미지 프로필 변경에 실패했습니다."
                    fail?(msg)
                }
            case.failure(let error):
                fail?(error.localizedDescription)
            }
        }
    }
}
