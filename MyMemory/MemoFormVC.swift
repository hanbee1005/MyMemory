//
//  MemoFormVC.swift
//  MyMemory
//
//  Created by 손한비 on 2021/07/26.
//

import UIKit

class MemoFormVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var subject: String!
    lazy var dao = MemoDAO()

    @IBOutlet var contents: UITextView!
    @IBOutlet var preview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contents.delegate = self
    }
    
    // 저장 버튼을 클릭했을 때 호출되는 메소드
    @IBAction func save(_ sender: UIBarButtonItem) {
        // 내용을 입력하지 않았을 경우, 경고
        guard self.contents.text?.isEmpty == false else {
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // MemoData 객체를 생성하고, 데이터를 담는다.
        let data = MemoData()
        
        data.title = self.subject  // 제목
        data.contents = self.contents.text  // 내용
        data.image = self.preview.image  // 이미지
        data.regdate = Date()  // 작성 시각
        
        // 앱 델리게이트 객체를 읽어온 다음, memolist 배열에 MemoData 객체를 추가
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.memolist.append(data)
        
        // 코어 데이터에 메모 데이터를 추가
        self.dao.insert(data)
        
        // 작성폼 화면을 종료하고, 이전 화면으로 되돌아간다.
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // 카메라 버튼을 클릭했을 때 호출되는 메소드
    @IBAction func pick(_ sender: UIBarButtonItem) {
        let chooseMode = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraOpen = UIAlertAction(title: "카메라", style: .default) { (_) in
            NSLog("Camera Open")
            
            // TODO: 카메라 화면을 열어 사진을 찍고 찍은 사진을 추가할 수 있도록 구성
        }
        
        let photoLibraryOpen = UIAlertAction(title: "사진 라이브러리", style: .default) { (_) in
            NSLog("PhotoLibrary Open")
            
            // 이미지 피커 인스턴스를 생성
            let picker = UIImagePickerController()
            
            picker.delegate = self
            picker.allowsEditing = true
            
            // 이미지 피커 화면을 표시
            self.present(picker, animated: false, completion: nil)
        }
        
        chooseMode.addAction(cameraOpen)
        chooseMode.addAction(photoLibraryOpen)
        
        self.present(chooseMode, animated: false, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
    
    // 이미지 선택을 완료했을 때 호출되는 메소드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 선택된 이미지를 미리보기에 표시한다.
        self.preview.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        // 이미지 피커 컨트롤러를 닫는다.
        picker.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        // 내용의 최대 15자리까지 읽어 subject 변수에 저장
        let contents = textView.text as NSString
        let length = ((contents.length > 15) ? 15 : contents.length)
        self.subject = contents.substring(with: NSRange(location: 0, length: length))
        
        // 네비게이션 타이틀에 표시한다.
        self.navigationItem.title = subject
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
