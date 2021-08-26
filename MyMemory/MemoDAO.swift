//
//  MemoDAO.swift
//  MyMemory
//
//  Created by 손한비 on 2021/08/26.
//

import UIKit
import CoreData

class MemoDAO {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func fetch() -> [MemoData] {
        var memoList = [MemoData]()
        
        // 1. 요청 객체 생성
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        
        // 1-1. 최신 글 순으로 정렬하도록 정렬 객체 생성
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]
        
        do {
            let resultset = try self.context.fetch(fetchRequest)
            
            // 2. 읽어온 결과 집합을 순회하면서 [MemoMO] 타입으로 변환
            for record in resultset {
                // 3. MemoData 객체를 생성한다.
                let data = MemoData()
                
                // 4. MemoMO 프로퍼티 값을 MemoData의 프로퍼티로 복사한다.
                data.title = record.title
                data.contents = record.contents
                data.regdate = record.regdate! as Date
                data.objectID = record.objectID
                
                // 4-1. 이미지가 있을 떄에만 복사
                if let image = record.image as Data? {
                    data.image = UIImage(data: image)
                }
                
                // 5. MemoData 객체를 MemoList 배열에 추가한다.
                memoList.append(data)
            }
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
        }
        
        return memoList
    }
}
