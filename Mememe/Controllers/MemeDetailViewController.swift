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
    func memePhotoFavoriteDidChange(_ index:Int)
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
        guard let meme:Meme = self.selectedMeme, let localIdentifier: String = meme.localIdentifier,
            let isFavorite: Bool = self.isFavorite else {
            return
        }
        self.memeDataManager.favorite(localIdentifier, completion: { (isSuccess) in
            if isSuccess {
                self.isFavorite = !isFavorite
                // delegate 있을 시 해당 index 찾은 후 memeFavoriteDidChange
                if let delegate = self.delegate {
                    for index in 0...self.memeDataManager.memes.count-1 {
                        if (meme.localIdentifier == self.memeDataManager.memes[index].localIdentifier) {
                            delegate.memePhotoFavoriteDidChange(index)
                            break
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.favoriteButtonEffect(!isFavorite)
                }
            }
        })
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        guard let meme:Meme = self.selectedMeme, let localIdentifier: String = meme.localIdentifier else {
            return
        }
        
        if #available(iOS 9.0, *) {
            let alertAction:UIAlertAction = UIAlertAction.init(title: Constants.Alert.deleteButtonTitle, style: .destructive, handler: { (action) in
                self.memeDataManager.delete(localIdentifier, completion: { (isSuccess) in
                    if isSuccess {
                        // UI 변경은 DispatchQueue Main Thread로 관리 
                        // Background Thread Crash 발생 방지
                        DispatchQueue.main.async {
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            })
            AppModel.Alert.show(self, title: Constants.Alert.deleteAlertTitle, message: Constants.Alert.deleteAlertMessage, alertAction: alertAction)
        } else {
            AppModel.Alert.show(self, title: Constants.Alert.deleteAlertTitle, message: Constants.Alert.deleteAlertMessage, buttonTitle: Constants.Alert.deleteButtonTitle)
        }
    }
    @IBAction func shareAction(_ sender: Any) {
        // Optional Binding
        if let meme = self.selectedMeme {
            let image = meme.image as Any
            // Any로 변환은 항상 성공하기 때문에 Optional Type Binding 사용 X
            let activityViewController:UIActivityViewController = UIActivityViewController.init(activityItems: [image], applicationActivities: nil)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}

// MARK : UIAlertViewDelegate - For iOS < 9
extension MemeDetailViewController:UIAlertViewDelegate {
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        guard let buttonTitle = alertView.buttonTitle(at: buttonIndex), buttonTitle == Constants.Alert.deleteButtonTitle, let meme:Meme = self.selectedMeme, let localIdentifier: String = meme.localIdentifier else {
            return
        }
        self.memeDataManager.delete(localIdentifier, completion: { (isSuccess) in
            if isSuccess {
                // UI 변경은 DispatchQueue Main Thread로 관리
                // Background Thread Crash 발생 방지
                DispatchQueue.main.async {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
}
