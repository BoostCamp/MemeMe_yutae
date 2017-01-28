//
//  MemeEditorFontViewControllerExtension.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import Foundation
import UIKit
// MARK : UICollectionViewDelegate, UICollectionViewDataSource - Font Collection View
extension MemeEditorViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fontData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifier.fontCollectionViewCell, for: indexPath) as! MemeFontCollectionViewCell
        cell.largeFontLabel.font = UIFont(name: self.fontData[indexPath.row], size: 30)
        cell.smallFontLabel.text = fontData[indexPath.row]
        self.updateFontCell()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCellIndexPath = indexPath
        self.topTextField.font = UIFont(name: fontData[indexPath.row], size: 40)
        self.bottomTextField.font = UIFont(name: fontData[indexPath.row], size: 40)
        self.updateFontCell()
    }
    
    // Selected Cell 효과
    func updateFontCell(){
        // 나머지는 기본 사항.
        for i in 0...fontData.count {
            if let selectedCell = self.fontCollectionView.cellForItem(at: IndexPath.init(row: i, section: 0)), let cell = selectedCell as? MemeFontCollectionViewCell {
                cell.largeFontLabel.layer.borderWidth = 0
                cell.smallFontLabel.textColor = UIColor.lightGray
            }
        }
        // 선택한 셀 효과 주기.
        if let indexPath = self.selectedCellIndexPath {
            if let selectedCell = self.fontCollectionView.cellForItem(at: indexPath), let cell = selectedCell as? MemeFontCollectionViewCell {
                    cell.largeFontLabel.layer.borderWidth = 4
                    cell.smallFontLabel.textColor = UIColor.theme
            }
        }
    }
}
