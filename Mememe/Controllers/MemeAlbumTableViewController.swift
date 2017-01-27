//
//  MemeAlbumTableViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit
import Photos

class MemeAlbumTableViewController: UITableViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // Single Ton 사용
    let memeDataManager = MemeDataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAlbumTableView()
    }
    
    func resetTableView(){
        memeDataManager.fetchMemesForAlbum {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                if self.memeDataManager.memes.count == 0 {
                    // alertAction, buttonTitle 기본으로 nil 값이 들어가지만 어떤 함수인지 명시를 위해
                    if #available(iOS 9.0, *) {
                        Constants.Alert.show(self, title: Constants.Alert.emptyAlertTitle, message: Constants.Alert.emptyAlertMessage, alertAction: nil)
                    } else {
                        Constants.Alert.show(self, title: Constants.Alert.emptyAlertTitle, message: Constants.Alert.emptyAlertMessage, buttonTitle: nil)
                    }
                }
            }
        }
    }
    
    func setupAlbumTableView(){
        // Edit 버튼으로 지정.
        self.navigationItem.leftBarButtonItem = editButtonItem
        // Data 받아오기
        self.resetTableView()
        // Add PhotoLibrary Observer 
        PHPhotoLibrary.shared().register(self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueIdentifier.detailFromTableView {
            let destinationViewController = segue.destination as! MemeDetailViewController
            if let indexPath = self.tableView.indexPathForSelectedRow{
                destinationViewController.selectedMeme = memeDataManager.memes[indexPath.row]
                destinationViewController.delegate = self
            }
            // 3D Touch 시 Force Touch
            else if let cell = sender as? MemeAlbumTableViewCell{
                destinationViewController.selectedImage = cell.memedImageView.image
            }
            // 뒤로가기 글씨 없애기.
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.SegueIdentifier.editFromTableView, sender: nil)
    }
    
    // Editing 버튼 눌렀을때
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Editing 에는 버튼 못누르게 하기.
        self.addButton.isEnabled = !editing
    }
    // MARK: - Table view data source
    // Height 조절
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 기본으로 Section 당 하나의 Row
        return memeDataManager.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // as! 무조건 Type Casting 이 되기 때문
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.albumTableViewCell, for: indexPath) as! MemeAlbumTableViewCell
        let meme:Meme = memeDataManager.memes[indexPath.row]
        if let createDate = meme.creationDate, let isFavorite = meme.isFavorite {
            cell.creationDateLabel.text = createDate.stringFromDate()
            cell.favoriteImageView.isHidden = !isFavorite
        }
        cell.memedImageView.image = meme.image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            // tableView row 제거.
            let deleteIndex = indexPath.row
            print("\(deleteIndex) tableView row Remove")
            if let localIdentifier = memeDataManager.memes[deleteIndex].localIdentifier {
                memeDataManager.delete(localIdentifier, completion: { (isSuccess) in
                    // 성공 했을 경우 핸들링
                    if isSuccess {
                        // UI 이기 때문에 main Thread 비동기 처리
                        DispatchQueue.main.async {
                            self.memeDataManager.memes.remove(at: deleteIndex)
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    }
                })
            }
        default:
            return
        }
    }
}

// Mark: PHPhotoLibraryChangeObserver PhotoLibrary Change 됬을때
extension MemeAlbumTableViewController : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // MemeMe 앨범 변경되었을때만 reloadData 아니면 guard 문을 활용하여 빠르게 종료
        guard let assetCollection = memeDataManager.fetchAssetCollectionForAlbum(), changeInstance.changeDetails(for: assetCollection) != nil else {
            return
        }
        print("photoLibraryDidChange")
        self.resetTableView()
    }
}
// Custom Delegation Favorite 바꿧을때 Table 리셋 
// Favorite는 PHPhotoLibraryChangeObserver 가 Observering 해주지 않기 때문에
extension MemeAlbumTableViewController : memeDetailViewControllerDelegate {
    func memePhotoFavoriteDidChange() {
        self.resetTableView()
    }
}
