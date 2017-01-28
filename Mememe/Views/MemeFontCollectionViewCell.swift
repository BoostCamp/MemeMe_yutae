//
//  FontCollectionViewCell.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit

class MemeFontCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var largeFontLabel: UILabel!
    @IBOutlet weak var smallFontLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization 할때 borderColor 지정
        self.largeFontLabel.layer.borderColor = UIColor.theme.cgColor
    }
}
