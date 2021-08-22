//
//  TutorialMasterVC.swift
//  MyMemory
//
//  Created by 손한비 on 2021/08/22.
//

import UIKit

class TutorialMasterVC: UIViewController, UIPageViewControllerDataSource {
    var pageVC: UIPageViewController!
    
    // 콘텐츠 뷰 컨트롤러에 들어갈 티이틀과 이미지
    var contentTitles = ["STEP1", "STEP2", "STEP3", "STEP4"]
    var contentImages = ["Page0", "Page1", "Page2", "Page3"]
    
    func getContentVC(atIndex idx: Int) -> UIViewController? {
        // 인덱스가 데이터 배열 크기 범위를 벗어나면 nil 반환
        guard self.contentTitles.count >= idx && self.contentTitles.count > 0 else {
            return nil
        }
        
        // "ContentsVC" 라는 Storyboard ID를 가진 뷰 컨트롤러의 인스턴스를 생성하고 캐스팅한다.
        guard let cvc = self.instanceTutorialVC(name: "ContentsVC") as? TutorialContentsVC else {
            return nil
        }
        
        // 컨텐츠 뷰 컨트롤러의 내용을 구성한다.
        cvc.titleText = self.contentTitles[idx]
        cvc.ImageFile = self.contentImages[idx]
        cvc.pageIndex = idx
        return cvc
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    // 현재 컨텐츠 뷰 컨트롤러보다 앞쪽에 올 컨텐츠 뷰 컨트롤러 객체
    // 즉, 현재의 상태에서 앞쪽으로 스와이프했을 때 보여줄 컨텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 현재 페이지 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        
        // 현재 인덱스가 맨 앞이라면 nil을 반환하고 종료
        guard index > 0 else {
            return nil
        }
        
        index -= 1  // 현재의 인덱스에서 하나를 뺌 (즉, 이전 페이지 인덱스)
        return self.getContentVC(atIndex: index)
    }
    
    // 현재 컨텐츠 뷰 컨트롤러보다 뒤쪽에 올 컨텐츠 뷰 컨트롤러 객체
    // 즉, 현재의 상태에서 뒤쪽으로 스와이프했을 때 보여줄 컨텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // 현재 페이지 인덱스
        guard var index = (viewController as! TutorialContentsVC).pageIndex else {
            return nil
        }
        
        index += 1  // 현재의 인덱스에서 하나를 더함 (즉, 다음 페이지 인덱스)
        
        // 현재 인덱스가 맨 뒤라면 nil을 반환하고 종료
        guard index < self.contentTitles.count else {
            return nil
        }
        
        return self.getContentVC(atIndex: index)
    }
}
