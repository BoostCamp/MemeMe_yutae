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
    
    // MARK: Meme Permission Related
    struct Permission {
        struct PermissionAlert {
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
                        self.openSetting(UIImagePickerControllerSourceType.camera, viewController : viewController)
                    } else {
                        isAuthorized = true
                    }
            default:
                let status = PHPhotoLibrary.authorizationStatus()
                if status != .authorized {
                    PHPhotoLibrary.requestAuthorization({ (status) in
                        if status != .authorized {
                            self.openSetting(UIImagePickerControllerSourceType.photoLibrary, viewController : viewController)
                        }
                    })
                } else {
                    isAuthorized = true
                }
            }
            return isAuthorized
        }
        
        static public func openSetting(_ sourceType:UIImagePickerControllerSourceType, viewController: UIViewController){
            var alertContent : PermissionAlert
            switch sourceType {
            case .camera :
                alertContent = PermissionAlert.init(type: "카메라")
            case .photoLibrary :
                alertContent = PermissionAlert.init(type: "앨범")
            default:
                return
            }
            
            if #available(iOS 9.0, *) {
                let alert = UIAlertController(title: alertContent.title, message: alertContent.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "설정", style: .default, handler: { (action:UIAlertAction) -> Void in
                    let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(settingsUrl!)
                    }
                }))
                alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                viewController.present(alert, animated: true, completion: nil)
            } else {
                // 9.0 미만
            }
        }
    }
    
    // MARK: Font Data
    static let fontsAvailable = UIFont.familyNames
    
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
