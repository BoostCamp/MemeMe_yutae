//
//  AppModel.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//
import Foundation
import UIKit

struct AppModel {
    
    static let memeEditSegueIdentifier = "memeEditorModalSegue"
    static let memeShowDetailSegueIdentifier = "showMemeDetailInfoSegue"
    static let albumCollectionCell = "decoAlbumCollectionViewCell"
    static let memeFontCollectionReusableIdentifier = "fontCollectionCell"
    
    static let memeAlbumCollectionReusableIdentifier = "memeAlbumCollectionCell"
    
    static let fontsAvailable = UIFont.familyNames
    static let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -1.0
        ] as [String : Any]
    
    static let defaultTopTextFieldText = "TOP"
    static let defaultBottomTextFieldText = "BOTTOM"
    
    
    struct PermissionAlert {
        var type:String
        var title:String
        var message:String
        init (type:String) {
            self.type = type
            self.title = "\(type) 접근 허가가 필요합니다."
            self.message = "설정 -> Meme \(type) 접근 허용"
        }
    }
    /*
    static let actionHandler =
        { (action: (UIAlertAction) -> Void) in
            switch action.style {
            case .default:
                if action.title == "설정" {
                    let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(settingsUrl!)
                    }
                } else {
                    
                }
            default:
                self.dismiss(animated: true, completion: nil)
            }
        }
    */
//    func actionHandler(action: UIAlertAction) {
//        switch action.style {
//        case .default:
//            if action.title == "라이브러리" {
//                self.showPicker(sourceType: .photoLibrary)
//            } else {
//                self.showPicker(sourceType: .savedPhotosAlbum)
//            }
//        default:
//            self.dismiss(animated: true, completion: nil)
//        }
//        
//    }
    
    // Mark: Related Permission
    
    
    
}
