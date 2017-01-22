//
//  MemePhotoAlbum.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import Foundation
import Photos

class MemePhotoAlbum : NSObject {
    static let albumName = "MemeMe"
    // Single Ton 패턴 사용
    static let shared = MemePhotoAlbum()
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
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: MemePhotoAlbum.albumName)
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
        fetchOptions.predicate = NSPredicate(format: "title = %@", MemePhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func fetchImagesForAlbum() -> [UIImage] {
        let assetCollection = self.fetchAssetCollectionForAlbum()
        let photoAssets = PHAsset.fetchAssets(in: assetCollection!, options: nil)
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
    
    func save(image: UIImage) -> Bool {
        var isSuccess:Bool = true
        if assetCollection == nil {
            return false
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
        }) { (isCompletion, error) in
            isSuccess = isCompletion
        }
        return isSuccess
    }
}
