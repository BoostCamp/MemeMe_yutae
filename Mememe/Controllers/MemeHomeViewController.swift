//
//  MemeHomeViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 26..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit
import Photos
class MemeHomeViewController: UIViewController {

    @IBOutlet weak var editorButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func albumAction(_ sender: Any) {
        if Constants.Permission.checkPhotoLibraryAndCameraPermission(.photoLibrary, viewController: self) {
            self.performSegue(withIdentifier: Constants.SegueIdentifier.albumFromHomeView, sender: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
