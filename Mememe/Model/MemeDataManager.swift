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
    static let shared: MemeDataManager = MemeDataManager()
    var memes:[Meme] = [Meme]()
    let photoLibrary:PHPhotoLibrary = PHPhotoLibrary.shared()
    var assetCollection: PHAssetCollection!
    
    override init() {
        super.init()
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        self.createAlbum()
        
         // 초기화 하기전에 Permission 체크를 하기 때문에 필요 없음.
        /*
         if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status) in
                
            })
         }
         
         if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
         } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
         }
         */
    }
    
    /*
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // 새로운 Album 만들기
            self.createAlbum()
        } else {
        }
    }
    */
    func createAlbum() {
        photoLibrary.performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: MemeDataManager.albumName)
        }) { isSuccess, error in
            if isSuccess {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
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
    
    func fetchMemesForAlbum(completion: () -> Void) {
        self.memes.removeAll()
        let photoAssets = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        let imageManager = PHCachingImageManager()
        photoAssets.enumerateObjects({ (asset:PHAsset, count:Int, stop:UnsafeMutablePointer<ObjCBool>) in
            var meme = Meme()
            let imageSize = CGSize(width: asset.pixelWidth,
                                   height: asset.pixelHeight)
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            // isSynchronous - BackGround Thread 로 실행
            options.isSynchronous = true
            imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFit, options: options,
              resultHandler: {
                (image, info) -> Void in
                meme.image = image
            })
            
            meme.localIdentifier = asset.localIdentifier
            meme.creationDate = asset.creationDate
            meme.isFavorite = asset.isFavorite
            self.memes.append(meme)
        })
        completion()
    }
    // favorite 주기. completion으로 성공시 핸들링
    func favorite(_ localIdentifier : String, completion: @escaping (( (Bool) -> Void)) ){
        let photoAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        photoAssets.enumerateObjects( { (asset, count, stop) in
            self.photoLibrary.performChanges({
                let assetChangeRequest = PHAssetChangeRequest(for: asset)
                // isFavorite 변경
                assetChangeRequest.isFavorite = !asset.isFavorite
            }, completionHandler: { (isSuccess, error) in
                if isSuccess {
                    completion(isSuccess)
                }
            })
        })
    }
    
    // 삭제 함수 completion으로 성공시 핸들링
    func delete(_ localIdentifier : String, completion: @escaping (( (Bool) -> Void)) ){
        let photoAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        photoAssets.enumerateObjects( { (asset, count, stop) in
            self.photoLibrary.performChanges({
                let isDelete = asset.canPerform(.delete)
                if isDelete {
                    let enumeration: NSArray = [asset]
                    PHAssetChangeRequest.deleteAssets(enumeration)
                }
            }, completionHandler: { (isSuccess, error) in
                if isSuccess {
                    completion(isSuccess)
                }
            })
        })
    }
    // 저장 함수 completion으로 성공시 핸들링
    func save(_ image: UIImage, completion: @escaping (( (Bool) -> Void)) ){
        if self.assetCollection == nil {
            // 앨범이 없을때 예외 처리
            return
        }
        // https://developer.apple.com/reference/photos/phassetchangerequest/1624056-placeholderforcreatedasset Swift로 변형
        
        self.photoLibrary.performChanges({
            // creationRequestForAsset 함수 Image 만들기 return Self
            
            // self.assetCollection 에 추가된 이미지 추가하기
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            // Optional binding
            if let placeHolder = assetChangeRequest.placeholderForCreatedAsset, let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)  {
                let enumeration: NSArray = [placeHolder]
                albumChangeRequest.addAssets(enumeration)
            }
        }) { (isSuccess, error) in
            completion(isSuccess)
        }
    }
}
