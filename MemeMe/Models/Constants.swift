//
//  Constants.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//
import Foundation
import UIKit

struct Constants {
    // MARK: Font Data
    static let fontsAvailable:[String] = UIFont.familyNames
    // MARK: StoryboardIdentifier
    struct StoryboardIdentifier{
        static let memeEditorView = "MemeEditorViewController"
    }
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
        static let edtingFontCollectionViewCell:String = "edtingFontCollectionViewCell"
    }
    // MARK: Meme Defaults Value
    struct MemeDefaultsValue {
        static let textAttributes = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -1.0
            ] as [String : Any]
        static let topTextFieldText = "TOP"
        static let bottomTextFieldText = "BOTTOM"
    }
    // MARK: UserDefaults Related
    struct UserDefaultsKey {
        static let fontName = "FontName"
    }
    // MARK: UserDefaults Related
    struct RestorationKey {
        static let topTextFieldText = "TopTextFieldText"
        static let bottomTextFieldText = "BottomTextFieldText"
    }
    // MARK: Alert Related
    struct Alert {
        static let settingsUrl:URL? = URL(string: UIApplicationOpenSettingsURLString)
        static let settingsButtonTitle:String = "설정"
        static let refreshButtonTitle:String = "되돌리기"
        static let deleteButtonTitle:String = "삭제"
        static let cancelButtonTitle:String = "취소"
        static let emptyAlertTitle:String = "MemeMe 앨범에 등록된 사진이 없습니다."
        static let emptyAlertMessage:String = "우측 상단위 + 버튼을 눌러 사진을 추가하세요."
        static let refreshAlertTitle:String = "정말 원 상태로 돌아가시겠습니까?"
        static let refreshAlertMessage:String = "확인을 누르시면 이 작업물은 앨범에 저장되지 않습니다."
        static let deleteAlertTitle:String = "정말 이 사진을 삭제하시겠습니까?"
        static let deleteAlertMessage:String = "사진이 성공적으로 지워지면 앨범으로 돌아갑니다."
    }
}
