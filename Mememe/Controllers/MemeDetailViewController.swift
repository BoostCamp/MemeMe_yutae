//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    var selectedMeme:Meme?
    var selectedImage:UIImage?
    // Single ton Pattern
    let memeDataManager:MemeDataManager = MemeDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Optional Binding
        print("MemeDetailViewController viewWillAppear")
        configureUI()
    }
    @IBAction func favoriteAction(_ sender: Any) {
        if let meme = self.selectedMeme, let localIdentifier = meme.localIdentifier {
            memeDataManager.favorite(localIdentifier)
        }
    }
    
    func configureUI(){
        if let meme = self.selectedMeme {
            self.imageView.image = meme.image
        }
            // 3D Touch로 눌렀을때
        else if let image = self.selectedImage {
            self.imageView.image = image
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
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

}
