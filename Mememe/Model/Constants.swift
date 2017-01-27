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
        static let detailFromTableView:String = "memeShowDetailFromTableViewSegue"
        static let detailFromCollectionView:String = "memeShowDetailFromCollectionViewSegue"
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
        static let settingsUrl:URL? = URL(string: UIApplicationOpenSettingsURLString)
        static let settingsButtonTitle:String = "설정"
        static let refreshButtonTitle:String = "되돌리기"
        static let deleteButtonTitle:String = "삭제"
        static let cancelButtonTitle:String = "취소"
        static let emptyAlertTitle:String = "MemeMe 앨범에 등록된 사진이 없습니다."
        static let emptyAlertMessage:String = "우측 상단위 + 버튼을 눌러 사진을 추가하세요."
    
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
            let cancelAlertAciton:UIAlertAction = UIAlertAction.init(title: cancelButtonTitle, style: .cancel, handler: nil)
            alertController.addAction(cancelAlertAciton)
            viewController.present(alertController, animated: true, completion: nil)
        }
        // iOS 9.0 미만
        static func show(_ delegate:Any?=nil, title: String?=nil, message: String?=nil, buttonTitle:String? = nil) {
            // 취소는 항상 넣기 때문에 고정
            let alertView:UIAlertView = UIAlertView.init(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButtonTitle)
             // Button은 취소 포함 2개 밖이 안쓰니 배열을 사용 안함
            if let buttonTitle = buttonTitle {
                alertView.addButton(withTitle: buttonTitle)
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
                if type == "카메라" {
                    self.message = self.message + "\n 카메라가 없는 기기일 경우 제한 됩니다."
                }
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
                let settingsAlertAction:UIAlertAction = UIAlertAction.init(title: Alert.settingsButtonTitle, style: .default, handler: { (action) in
                    if let settingsUrl = Alert.settingsUrl {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(settingsUrl)
                        }
                    }
                })
                Constants.Alert.show(viewController, title: alertContent.title, message: alertContent.message, alertAction: settingsAlertAction)
            }
            // iOS 9.0 미만
            else {
                Constants.Alert.show(viewController, title: alertContent.title, message: alertContent.message, buttonTitle: Alert.settingsButtonTitle)
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
