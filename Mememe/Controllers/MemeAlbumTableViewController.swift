//
//  MemeAlbumTableViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit

class MemeAlbumTableViewController: UITableViewController {
    
    // Single Ton 사용
    let memeDataManager = MemeDataManager.shared
    var memes = [Meme]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
            if let meme = sender as? Meme {
                destination.selectedMeme = meme
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
        self.performSegue(withIdentifier: AppModel.memeDetailFromTableViewSegueIdentifier, sender: self.memes[indexPath.section])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // as! 무조건 Type Casting 이 되기 때문
        let cell = tableView.dequeueReusableCell(withIdentifier: AppModel.memeAlbumTableReusableIdentifier, for: indexPath) as! MemeAlbumTableViewCell
        let meme:Meme = self.memes[indexPath.section]
        cell.creationDateLabel.text = meme.creationDate.stringFromDate()
        cell.memedImageView.image = meme.image
        return cell
    }
}
