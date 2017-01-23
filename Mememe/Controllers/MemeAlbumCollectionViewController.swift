//
//  MemeAlbumCollectionViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit

class MemeAlbumCollectionViewController: UICollectionViewController {

    // Single Ton 사용
    let memeDataManager = MemeDataManager.shared
    var memes = [Meme]()
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memes = memeDataManager.fetchMemesForAlbum()
        self.collectionView?.reloadData()
    }
    func setupLayout(){
        let space: CGFloat
        let width: CGFloat
        if (UIDeviceOrientationIsPortrait(UIDevice.current.orientation)) {
            // Portrait 일때 각 라인당 3개, Landscape 5개 Rotation 도 적용
            space = 4.0
            width = (view.frame.size.width - (2 * space)) / 3
        } else {
            space = 2.0
            width = (view.frame.size.width - (1 * space)) / 5
        }
        // 1:1 비율로 width, height 크기가 같음.
        self.flowLayout.itemSize = CGSize(width: width, height: width)
        self.flowLayout.minimumInteritemSpacing = space
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // as! 무조건 Type Casting 이 되기 때문
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppModel.memeAlbumCollectionReusableIdentifier, for: indexPath) as! MemeAlbumCollectionViewCell
        cell.memedImageView.image = memes[indexPath.item].image
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: AppModel.memeShowDetailSegueIdentifier, sender: self.memes[indexPath.item])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppModel.memeShowDetailSegueIdentifier {
            let destination = segue.destination as! MemeDetailViewController
            if let meme = sender as? Meme {
                destination.selectedMeme = meme
            }
        }
    }

}
