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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupLayout()
        memes = memeDataManager.fetchMemesForAlbum()
        self.collectionView?.reloadData()
    }
    func setupLayout(){
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
    }
    
    @IBAction func addAction(_ sender: Any) {
        self.performSegue(withIdentifier: AppModel.memeEditFromCollectionViewSegueIdentifier, sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppModel.memeDetailFromCollectionViewSegueIdentifier {
            let destination = segue.destination as! MemeDetailViewController
            if let meme = sender as? Meme {
                destination.selectedMeme = meme
            }
            // 뒤로가기 글씨 없애기.
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        if segue.identifier == AppModel.memeEditFromCollectionViewSegueIdentifier {
            
        }
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
        self.performSegue(withIdentifier: AppModel.memeDetailFromCollectionViewSegueIdentifier, sender: self.memes[indexPath.item])
    }
    
    

}
