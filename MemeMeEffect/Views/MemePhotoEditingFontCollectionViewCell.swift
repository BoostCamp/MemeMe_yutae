//
//  MemeFontCollectionViewCell.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 24..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit

class MemePhotoEditingFontCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var largeFontLabel: UILabel!
    @IBOutlet weak var smallFontLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.largeFontLabel.layer.borderColor = UIColor.theme.cgColor
    }
}
