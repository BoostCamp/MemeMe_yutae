//
//  MemeAlbumCollectionViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit
import Photos

class MemeAlbumCollectionViewController: UICollectionViewController {

    // Single Ton 사용
    let memeDataManager = MemeDataManager.shared
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAlbumCollectionView()
    }
    // MARK: Setup Collection View
    func setupAlbumCollectionView(){
        // Setup Layout
        let space: CGFloat
        let width: CGFloat
        if UIDevice.current.orientation.isLandscape {
            space = 1.0
            width = (self.view.frame.size.width - (1 * space)) / 6
        } else {
            space = 3.0
            width = (self.view.frame.size.width - (2 * space)) / 3
        }
        // 1:1 비율로 width, height 크기가 같음.
        self.flowLayout.itemSize = CGSize(width: width, height: width)
        self.flowLayout.minimumInteritemSpacing = space
        
        // Add PhotoLibrary Observer
        PHPhotoLibrary.shared().register(self)
        self.resetCollectionView()
    }
    func resetCollectionView(){
        memeDataManager.fetchMemesForAlbum {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                if self.memeDataManager.memes.count == 0 {
                    // alertAction, buttonTitle 기본으로 nil 값이 들어가지만 어떤 함수인지 명시를 위해
                    if #available(iOS 9.0, *) {
                        AppModel.Alert.show(self, title: Constants.Alert.emptyAlertTitle, message: Constants.Alert.emptyAlertMessage, alertAction: nil)
                    } else {
                        AppModel.Alert.show(self, title: Constants.Alert.emptyAlertTitle, message: Constants.Alert.emptyAlertMessage, buttonTitle: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.SegueIdentifier.editFromCollectionView, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueIdentifier.detailFromCollectionView {
            let destinationViewController = segue.destination as! MemeDetailViewController
            if let indexPath = self.collectionView?.indexPathsForSelectedItems?.first {
                destinationViewController.selectedMeme = memeDataManager.memes[indexPath.item]
                destinationViewController.delegate = self
            }
                // 3D Touch 시 Force Touch
            else if let cell = sender as? MemeAlbumCollectionViewCell {
                destinationViewController.selectedImage = cell.memedImageView.image
            }
            // 뒤로가기 글씨 없애기.
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memeDataManager.memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // as! 무조건 Type Casting 이 되기 때문
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifier.albumCollectionViewCell, for: indexPath) as! MemeAlbumCollectionViewCell
        let meme = memeDataManager.memes[indexPath.item]
        if let isFavorite = meme.isFavorite {
            cell.favoriteImageView.isHidden = !isFavorite
        }
        cell.memedImageView.image = meme.image
    
        return cell
    }
}


// Mark: PHPhotoLibraryChangeObserver PhotoLibrary Change 됬을때
extension MemeAlbumCollectionViewController : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // MemeMe 앨범 변경되었을때만 reloadData 아니면 guard 문을 활용하여 빠르게 종료
        guard let assetCollection = memeDataManager.fetchAssetCollectionForAlbum(), changeInstance.changeDetails(for: assetCollection) != nil else {
            return
        }
        print("photoLibraryDidChange")
        self.resetCollectionView()
    }
}

// Favorite는 PHPhotoLibraryChangeObserver 가 Observering 해주지 않기 때문에
// Custom Delegation Favorite 바꿧을때 해당 Reload!
extension MemeAlbumCollectionViewController : memeDetailViewControllerDelegate {
    func memePhotoFavoriteDidChange(_ index: Int) {
        self.resetCollectionView()
    }
}
