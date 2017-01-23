//
//  DateExtension.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 23..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import Foundation

extension Date {
    func stringFromDate() -> String {
        let dataFormat = DateFormatter.init()
        // a - PM/ AM 구별, HH- 0~24, hh - 1~12
        dataFormat.dateFormat = "YYYY년 MM월 DD일 a hh:mm"
        dataFormat.locale = Locale.init(identifier: "ko_KR")
        return dataFormat.string(from: self)
    }
}
