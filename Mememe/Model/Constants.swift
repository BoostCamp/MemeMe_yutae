//
//  Constants.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//
import Foundation
import UIKit
import Photos
import AVFoundation

struct Constants {
    // MARK: Segue Identifiers
    struct SegueIdentifier {
        static let editFromHomeView:String = "memeEditorModalFromHomeViewControllerSegue"
        static let editFromTableView:String = "memeEditorModalFromTableViewSegue"
        static let editFromCollectionView:String = "memeEditorModalFromCollectionViewSegue"
        static let albumFromHomeView:String = "memeAlbumFromHomeViewControllerSegue"
        static let detailFromTableView:String = "showMemeDetailFromTableViewSegue"
        static let detailFromCollectionView:String = "showMemeDetailFromCollectionViewSegue"
    }
    // MARK: Table View Cell & Collection View Cell Identifiers
    struct CellIdentifier {
        static let fontCollectionViewCell:String = "fontCollectionViewCell"
        static let albumTableViewCell:String = "memeTableViewCell"
        static let albumCollectionViewCell:String = "memeAlbumCollectionViewCell"
    }
    // MARK: Meme Defaults Value
    struct MemeDefaultsValue {
//        if let UserDefaults.standard
        static let textAttributes = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -1.0
            ] as [String : Any]
        static let topTextFieldText = "TOP"
        static let bottomTextFieldText = "BOTTOM"
    }
    
    struct UserDafaultsKey {
        static let fontName = "FontName"
    }
    struct Alert {
        /* actionHandler viewController 필요한 Alert가 많아서 사용하지 않았습니다.
        static let actionHandler =
            { (action: (UIAlertAction)) in
                switch action.style {
                case .default:
                    switch action.title {
                        case "설정":
                            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(settingsUrl!)
                            }
                        default:
                            print("Default")
                    }
                default:
                    self.dismiss(animated: true, completion: nil)
                }
            }
        */
        // iOS 9.0 이상
        static func show(_ viewController : UIViewController, title: String?=nil, message: String?=nil, alertAction:UIAlertAction? = nil){
            // UIAlertAction 는 취소 포함 2개 밖이 안쓰니 배열을 사용 안함
            let alertController:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if let alertAction = alertAction {
                alertController.addAction(alertAction)
            }
            // 취소는 항상 넣기 때문에 고정
            let cancelAlertAciton:UIAlertAction = UIAlertAction.init(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(cancelAlertAciton)
            viewController.present(alertController, animated: true, completion: nil)
        }
        // iOS 9.0 미만
        static func show(_ delegate:Any?=nil, title: String?=nil, message: String?=nil, buttonTitles:[String]? = nil, cancelButtonTitle:String?=nil) {
            let alertView:UIAlertView = UIAlertView.init(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButtonTitle)
            // 추가할 button 이 있을때
            if let buttonTitles = buttonTitles {
                for buttonTitle in buttonTitles {
                    alertView.addButton(withTitle: buttonTitle)
                }
            }
            alertView.show()
        }
    }
    // MARK: Meme Permission Related
    struct Permission {
        struct AlertContent {
            var type:String
            var title:String
            var message:String
            init (type:String) {
                self.type = type
                self.title = "\(type) 접근 허가가 필요합니다."
                self.message = "설정 -> MemeMe \(type) 접근 허용"
            }
        }
        static public func checkPhotoLibraryAndCameraPermission(_ sourceType:UIImagePickerControllerSourceType) -> Bool{
            var isAuthorized = false
            switch sourceType {
            case .camera:
                let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                if status == .authorized {
                    isAuthorized = true
                }
            default:
                let status = PHPhotoLibrary.authorizationStatus()
                if status == .authorized {
                    isAuthorized = true
                }
            }
            return isAuthorized
        }
        
        static public func checkPhotoLibraryAndCameraPermission(_ sourceType:UIImagePickerControllerSourceType, viewController: UIViewController) -> Bool{
            var isAuthorized = false

            switch sourceType {
                case .camera:
                    let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                    if status != .authorized {
                        let alertContent:AlertContent = AlertContent.init(type: "카메라")
                        self.openSettings(viewController,alertContent:alertContent)
                    } else {
                        isAuthorized = true
                    }
            default:
                let status = PHPhotoLibrary.authorizationStatus()
                if status != .authorized {
                    PHPhotoLibrary.requestAuthorization({ (status) in
                        if status != .authorized {
                            let alertContent:AlertContent = AlertContent.init(type: "앨범")
                            self.openSettings(viewController,alertContent:alertContent)
                        }
                    })
                } else {
                    isAuthorized = true
                }
            }
            return isAuthorized
        }
        
        static public func openSettings(_ viewController: UIViewController, alertContent:AlertContent){
            if #available(iOS 9.0, *) {
                let settingsAlertAction:UIAlertAction = UIAlertAction.init(title: "설정", style: .default, handler: { (action) in
                    let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(settingsUrl!)
                    }
                })
                Constants.Alert.show(viewController, title: alertContent.title, message: alertContent.message, alertAction: settingsAlertAction)
            }
            // iOS 9.0 미만
            else {
                Constants.Alert.show(viewController, title: alertContent.title, message: alertContent.message, buttonTitles: ["설정"], cancelButtonTitle: "취소")
            }
        }
    }
    
    // MARK: Font Data
    static let fontsAvailable = UIFont.familyNames
    
    /*
    
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
