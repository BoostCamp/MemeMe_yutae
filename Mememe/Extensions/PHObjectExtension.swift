//
//  PHObjectExtension.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 26..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import Foundation
import Photos

extension PHObject {
    public var topTextFieldText:String? {
        get {
            return self.topTextFieldText
        }
        set {
            self.topTextFieldText = newValue
        }
    }
}
