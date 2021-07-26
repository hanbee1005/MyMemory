//
//  MemoCell.swift
//  MyMemory
//
//  Created by 손한비 on 2021/07/26.
//

import UIKit

class MemoCell: UITableViewCell {
    @IBOutlet var subject: UILabel!   // 메모 제목
    @IBOutlet var contents: UILabel!  // 메모 내용
    @IBOutlet var regdate: UILabel!   // 등록 일자
    @IBOutlet var img: UIImageView!   // 이미지
}
