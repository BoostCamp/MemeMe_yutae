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
    var selectedMeme:Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Optional Binding
        if let meme = self.selectedMeme {
            self.imageView.image = meme.image
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func shareAction(_ sender: Any) {
        // Optional Binding
        if let meme = self.selectedMeme {
            let activityViewController = UIActivityViewController(activityItems: [meme.image], applicationActivities: nil)
            // Air Drop 잘 안쓰기 때문에 생략.
            activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
            // Completion Handler
//            activityViewController.completionWithItemsHandler = { activity, success, items, error in
//            }
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

}
