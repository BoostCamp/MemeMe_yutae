//
//  MemeHomeViewController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 26..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit
class MemeHomeViewController: UIViewController {

    @IBOutlet weak var editorButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHomeView()
    }
    
    func setupHomeView(){
        self.buttonInsertEffects(self.editorButton)
        self.buttonInsertEffects(self.albumButton)
    }
    
    func buttonInsertEffects(_ button : UIButton) {
        button.layer.cornerRadius = 20.0
    }
    
    @IBAction func albumAction(_ sender: Any) {
        if Constants.Permission.checkPhotoLibraryAndCameraPermission(.photoLibrary, viewController: self) {
            self.performSegue(withIdentifier: Constants.SegueIdentifier.albumFromHomeView, sender: nil)
        }
    }
    
}
