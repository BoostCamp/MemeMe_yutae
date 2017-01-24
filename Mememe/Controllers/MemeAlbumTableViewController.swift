//
//  MemeAlbumTableViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit

class MemeAlbumTableViewController: UITableViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // Single Ton 사용
    let memeDataManager = MemeDataManager.shared
    var memes = [Meme]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Edit 버튼으로 지정.
//        self.editButton = editButtonItem
        self.navigationItem.leftBarButtonItem = editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memes = memeDataManager.fetchMemesForAlbum()
        self.tableView?.reloadData()
        print("MemeAlbumTableViewController viewWillAppear")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppModel.memeDetailFromTableViewSegueIdentifier {
            let destination = segue.destination as! MemeDetailViewController
            if let indexPath = self.tableView.indexPathForSelectedRow{
                destination.selectedMeme = self.memes[indexPath.section]
            }
            // 3D Touch 시 Force Touch
            else if let cell = sender as? MemeAlbumTableViewCell{
                destination.selectedImage = cell.memedImageView.image
            }
            // 뒤로가기 글씨 없애기.
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        if segue.identifier == AppModel.memeEditFromTableViewSegueIdentifier {
//            let destination = segue.destination as! MemeEditorViewController
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        self.performSegue(withIdentifier: AppModel.memeEditFromTableViewSegueIdentifier, sender: nil)
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
        print("didSelectRowAt")
        
//        self.performSegue(withIdentifier: AppModel.memeDetailFromTableViewSegueIdentifier, sender: self.memes[indexPath.section])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // as! 무조건 Type Casting 이 되기 때문
        let cell = tableView.dequeueReusableCell(withIdentifier: AppModel.memeAlbumTableReusableIdentifier, for: indexPath) as! MemeAlbumTableViewCell
        let meme:Meme = self.memes[indexPath.section]
        cell.creationDateLabel.text = meme.creationDate.stringFromDate()
        cell.memedImageView.image = meme.image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            // tableView Section 제거.
            let deleteIndex = indexPath.section
            print("\(deleteIndex) tableView Section Remove")
            memeDataManager.delete(self.memes[deleteIndex].localIdentifier)
            self.memes.remove(at: deleteIndex)
            tableView.deleteSections(IndexSet.init(integer: deleteIndex), with: .automatic)
        default:
            return
        }
    }
}
