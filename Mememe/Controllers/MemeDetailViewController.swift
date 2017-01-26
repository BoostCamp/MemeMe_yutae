//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit
// Custom Delegation
protocol memeDetailViewControllerDelegate {
    func memeFavoriteDidChange()
}

class MemeDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    @IBOutlet weak var toolBar: UIToolbar!
    var selectedMeme:Meme?
    var selectedImage:UIImage?
    var isFavorite:Bool?
    var delegate:memeDetailViewControllerDelegate?
    // Single ton Pattern
    let memeDataManager:MemeDataManager = MemeDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupDetailView()
    }
    @IBAction func favoriteAction(_ sender: Any) {
        if let meme:Meme = self.selectedMeme, let localIdentifier: String = meme.localIdentifier,
           let isFavorite: Bool = self.isFavorite {
            self.memeDataManager.favorite(localIdentifier, completion: { (isSuccess) in
                if isSuccess {
                    self.isFavorite = !isFavorite
                    // delegate 있을 시 memeFavoriteDidChange
                    self.delegate?.memeFavoriteDidChange()
                    DispatchQueue.main.async {
                        self.favoriteButtonEffect(!isFavorite)
                    }
                }
            })
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        
    }
    @IBAction func shareAction(_ sender: Any) {
        // Optional Binding
        if let meme = self.selectedMeme {
            let activityViewController = UIActivityViewController(activityItems: [meme.image], applicationActivities: nil)
            // Air Drop 잘 안쓰기 때문에 생략.
            activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    private func setupDetailView(){
        if let meme = self.selectedMeme {
            self.imageView.image = meme.image
            self.isFavorite = meme.isFavorite
            self.favoriteButtonEffect(self.isFavorite)
            self.toolBar.isHidden = false
        }
            // 3D Touch로 눌렀을때
        else if let image = self.selectedImage {
            self.imageView.image = image
            self.toolBar.isHidden = true
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func favoriteButtonEffect(_ isFavorite: Bool?){
        if let favorite = isFavorite {
            self.favoriteButton.tintColor = favorite ? UIColor.red : UIColor.theme
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

}
