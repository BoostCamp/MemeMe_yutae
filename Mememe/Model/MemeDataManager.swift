//
//  MemePhotoAlbum.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import Foundation
import Photos
import RealmSwift

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
    
    func fetchImagesForAlbum() -> [UIImage] {
        let photoAssets = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        let imageManager = PHCachingImageManager()
        var images = [UIImage]()
        photoAssets.enumerateObjects({(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset{
                let asset = object as! PHAsset
                let imageSize = CGSize(width: asset.pixelWidth,
                                       height: asset.pixelHeight)
                let options = PHImageRequestOptions()
                options.deliveryMode = .fastFormat
                options.isSynchronous = true
                imageManager.requestImage(for:
                    asset,
                    targetSize: imageSize,
                    contentMode: .aspectFit,
                    options: options,
                    resultHandler: {
                    (image, info) -> Void in
                    images.append(image!)
                })
            }
        })
        return images
    }
    
    func save(topText: String, bottomText:String, image: UIImage) {
//        var isSuccess:Bool = true
        let meme = Meme()
        meme.topText = topText
        meme.bottomText = bottomText
        
        guard let realm = try? Realm() else {
            // Error 핸들링
            print("ERROR!!!!!")
            return
        }
        meme.save()
        /* Select
        do {
            dump(realm.objects(Meme.self))
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
        */
        if assetCollection == nil {
            return
        }
        
        // https://developer.apple.com/reference/photos/phassetchangerequest/1624056-placeholderforcreatedasset Swift로 변형
        
        PHPhotoLibrary.shared().performChanges({
            // creationRequestForAsse t함수 Image 만들기 return Self
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            // self.assetCollection 에 추가된 이미지 추가하기
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            
            dump(assetChangeRequest)
            dump(assetPlaceHolder)
            dump(albumChangeRequest)
            dump(enumeration)
            albumChangeRequest!.addAssets(enumeration)
        }) { (isCompletion, error) in
            print(isCompletion)
//            dump(albumChangeRequest)
        }
    }
}
