//
//  MemePhotoAlbum.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import Foundation
import Photos

class MemeDataManager : NSObject {
    static let albumName = "MemeMe"
    // Single Ton 패턴 사용
    static let shared = MemeDataManager()
    var assetCollection: PHAssetCollection!
    
    override init() {
        super.init()
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        self.createAlbum()
        /*
         if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
         PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
         ()
         })
         }
         
         if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
         self.createAlbum()
         } else {
         PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
         }
         */
    }
    
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // 새로운 Album 만들기
            self.createAlbum()
        } else {
            print("예외 처리")
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: MemeDataManager.albumName)
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                print("error \(error)")
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", MemeDataManager.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func fetchMemesForAlbum() -> [Meme] {
        let photoAssets = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        let imageManager = PHCachingImageManager()
        var memes = [Meme]()
        
        photoAssets.enumerateObjects({(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            // 앨범에 있는 모든 사진 반복
            if object is PHAsset{
                var meme = Meme()
                let asset = object as! PHAsset
                let imageSize = CGSize(width: asset.pixelWidth,
                                       height: asset.pixelHeight)
                let options = PHImageRequestOptions()
                options.deliveryMode = .fastFormat
                // isSynchronous - BackGround Thread 로 실행
                options.isSynchronous = true
                imageManager.requestImage(for:
                    asset,
                    targetSize: imageSize,
                    contentMode: .aspectFit,
                    options: options,
                    resultHandler: {
                    (image, info) -> Void in
                    meme.image = image
                })
                meme.localIdentifier = asset.localIdentifier
                meme.creationDate = asset.creationDate
                meme.isFavorite = asset.isFavorite
                memes.append(meme)
            }
        })
        return memes
    }
    // 삭제 함수
    func delete(_ localIdentifier : String){
        let photoAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        photoAssets.enumerateObjects( { (object, count, stop) in
            PHPhotoLibrary.shared().performChanges({
                let isEditing = object.canPerform(.delete)
                if isEditing {
                    print("Delete Success")
                    let enumeration: NSArray = [object]
                    PHAssetChangeRequest.deleteAssets(enumeration)
                }
            }, completionHandler: { (isSuccess, error) in
                
            })
        })
    }
    
    func save(_ image: UIImage) {
        if self.assetCollection == nil {
            // 앨범까지 전체 삭제 되었을때의 예외 처리
            return
        }
        // https://developer.apple.com/reference/photos/phassetchangerequest/1624056-placeholderforcreatedasset Swift로 변형
        
        PHPhotoLibrary.shared().performChanges({
            // creationRequestForAsse t함수 Image 만들기 return Self
            
            // self.assetCollection 에 추가된 이미지 추가하기
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            // Optional binding
            if let placeHolder = assetPlaceHolder, let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)  {
                let enumeration: NSArray = [placeHolder]
                albumChangeRequest.addAssets(enumeration)
            }
        }) { (isSuccess, error) in
            if isSuccess {
                
            }
        }
    }
}
