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
    let photoLibrary = PHPhotoLibrary.shared()
    var memes = [Meme]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAlbumTableView()
    }
    
    
    func setupAlbumTableView(){
        // Edit 버튼으로 지정.
        self.navigationItem.leftBarButtonItem = editButtonItem
        // Data 받아오기
        self.memes = memeDataManager.fetchMemesForAlbum()
        self.tableView?.reloadData()
        //
        self.photoLibrary.register(self)
    }
    func removePhotoLibraryDidChangedObserver(){
//        self.photoLibrary.re
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueIdentifier.detailFromTableView {
            let destinationViewController = segue.destination as! MemeDetailViewController
            if let indexPath = self.tableView.indexPathForSelectedRow{
                destinationViewController.selectedMeme = self.memes[indexPath.section]
            }
            // 3D Touch 시 Force Touch
            else if let cell = sender as? MemeAlbumTableViewCell{
                destinationViewController.selectedImage = cell.memedImageView.image
            }
            // 뒤로가기 글씨 없애기.
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }

        if segue.identifier == Constants.SegueIdentifier.editFromTableView {
//            let destination = segue.destination as! MemeEditorViewController
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.SegueIdentifier.editFromTableView, sender: nil)
    }
    
    // 기본으로 탑재되어 있는 Editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Editing 에는 버튼 못누르게 하기.
        self.addButton.isEnabled = !editing
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // 갯수 지정
        return self.memes.count
    }
    
    // Height 조절
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 기본으로 Section 당 하나의 Row
        return 1
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // as! 무조건 Type Casting 이 되기 때문
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.albumTableViewCell, for: indexPath) as! MemeAlbumTableViewCell
        let meme:Meme = self.memes[indexPath.section]
        if let createDate = meme.creationDate {
            cell.creationDateLabel.text = createDate.stringFromDate()
        }
        cell.memedImageView.image = meme.image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            // tableView Section 제거.
            let deleteIndex = indexPath.section
            print("\(deleteIndex) tableView Section Remove")
            if let localIdentifier = self.memes[deleteIndex].localIdentifier {
                memeDataManager.delete(localIdentifier)
            }
            self.memes.remove(at: deleteIndex)
            tableView.deleteSections(IndexSet.init(integer: deleteIndex), with: .automatic)
        default:
            return
        }
    }
}

// Mark: PHPhotoLibraryChangeObserver PhotoLibrary Change 됬을때
extension MemeAlbumTableViewController : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        // MemeMe 앨범 변경되었을때만 reloadData
        if let assetCollection = memeDataManager.fetchAssetCollectionForAlbum() {
            if changeInstance.changeDetails(for: assetCollection) != nil {
                self.memes = memeDataManager.fetchMemesForAlbum()
                self.tableView.reloadData()
            }
        }
        
    }
}
