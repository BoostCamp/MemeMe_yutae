//
//  MemeEditorFontViewControllerExtension.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import Foundation
import UIKit
extension MemeEditorViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fontData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifier.fontCollectionViewCell, for: indexPath) as! MemeFontCollectionViewCell
        cell.largeNameLabel.font = UIFont(name: self.fontData[indexPath.row], size: 30)
        cell.smallNameLabel.text = fontData[indexPath.row]
        self.updateCell()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCellIndexPath = indexPath
        self.topTextField.font = UIFont(name: fontData[indexPath.row], size: 40)
        self.bottomTextField.font = UIFont(name: fontData[indexPath.row], size: 40)
        self.updateCell()
    }
    
    // Selected Cell 효과
    func updateCell(){
        // 나머지는 기본 사항.
        for i in 0...fontData.count {
            if let selectedCell = self.fontCollectionView.cellForItem(at: IndexPath.init(row: i, section: 0)) {
                let cell = selectedCell as! MemeFontCollectionViewCell
                cell.largeNameLabel.layer.borderWidth = 0
                cell.smallNameLabel.textColor = UIColor.lightGray
            }
        }
        // 선택한 셀 효과 주기.
        if let indexPath = self.selectedCellIndexPath {
            if let selectedCell = self.fontCollectionView.cellForItem(at: indexPath) {
                    let cell = selectedCell as! MemeFontCollectionViewCell
                    cell.largeNameLabel.layer.borderWidth = 4
                    cell.smallNameLabel.textColor = UIColor.theme
            }
        }
    }
}
