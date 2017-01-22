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
    var selectedImage:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Optional Binding
        if let image = self.selectedImage {
            self.imageView.image = image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func shareAction(_ sender: Any) {
        // Optional Binding
        if let image = self.selectedImage {
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            // Air Drop 잘 안쓰기 때문에 생략.
            activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
            // Completion Handler
//            activityViewController.completionWithItemsHandler = { activity, success, items, error in
//            }
            self.present(activityViewController, animated: true, completion: nil)
        }
    }

}
