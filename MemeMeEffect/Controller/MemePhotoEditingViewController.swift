//
//  PhotoEditingViewController.swift
//  MemeMeEffect
//
//  Created by 최유태 on 2017. 1. 24..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class MemePhotoEditingViewController: UIViewController, PHContentEditingController {

    var input: PHContentEditingInput?
    
    @IBOutlet weak var memeView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var fontCollectionView: UICollectionView!
    @IBOutlet weak var fontButton: UIButton!
    
    
    // 이곳에서만 사용하기 때문에
    var selectedCellIndexPath:IndexPath?
    let photoEditingFontCollectionReusableIdentifier : String = "memePhotoEditingFontCollectionReusableIdentifier"
    let fontData = UIFont.familyNames
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -1.0
        ] as [String : Any]
    
    let themeColor : UIColor = UIColor.init(red: 0/255, green: 184/255, blue: 185/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fontCollectionView.delegate = self
        self.fontCollectionView.dataSource = self
        
        self.fontButton.layer.cornerRadius = self.fontButton.frame.height / 2
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // image load 한 후 configureUI
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.subscribeToKeyboardNotifications()
        self.configureUI()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 안전하게 완전히 사라진 후 Observer 제거
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        // image Load
        self.imageView.image = placeholderImage
        input = contentEditingInput
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            if let url = self.input?.fullSizeImageURL {
//                let originalImage = UIImage.init(contentsOfFile: url.path)
                let memedImage = self.generateMemedImage()
//                let renderedData = UIImageJPEGRepresentation(memedImage, 1.0)
                
//                if try? renderedData?.write(to: output.renderedContentURL, options: [.atomic]) {
//                    let archivedData = NSKeyedArchiver.archivedData(withRootObject: <#T##Any#>)
//                }
                
                if let renderedJPEGData =
                    UIImageJPEGRepresentation(memedImage, 0.9) {
                    try! renderedJPEGData.write(to:
                        output.renderedContentURL)
                }
                let archivedData =
                    NSKeyedArchiver.archivedData(
                        withRootObject: "MemeMe")
                
                let adjustmentData =
                    PHAdjustmentData(formatIdentifier:
                        "com.connect.MemeMe",
                         formatVersion: "1.0",
                         data: archivedData)
                
                output.adjustmentData = adjustmentData
            }
            
            // Provide new adjustments and render output to given location.
            // output.adjustmentData = new adjustment data
            // let renderedJPEGData = output JPEG
            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
            
            // Call completion handler to commit edit to Photos.
            completionHandler(output)
            
            // Clean up temporary files, etc.
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return false
    }
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }
    
    private func configureUI() {
        self.fontCollectionView.isHidden = true
        self.setupTextFields(self.topTextField, text: "TOP")
        self.setupTextFields(self.bottomTextField, text: "BOTTOM")
    }
    @IBAction func setFontAction(_ sender: Any) {
        self.fontCollectionView.isHidden = !self.fontCollectionView.isHidden
    }
    
    private func setupTextFields(_ textField: UITextField, text: String) {
        textField.defaultTextAttributes = self.memeTextAttributes
        textField.text = text
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self;
    }
    
    // MARK: Notification Funtions
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: Keyboard Related Methods and Delegates
    func keyboardWillShow(notification: NSNotification) {
        if self.bottomTextField.isFirstResponder {
            // bottom Textfield 편집시 bottom tool bar hide
//            self.bottomToolbar.isHidden = true
            view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
//        self.bottomToolbar.isHidden = false
    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        // 원본에서 필요한방법으로 수정 (Tool Bar 숨길 필요 없음.)
        UIGraphicsBeginImageContext(self.memeView.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            self.memeView.layer.render(in: context)
        }
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return memedImage
    }
}

extension MemePhotoEditingViewController: UITextFieldDelegate {
    // 이전에 써져있는 글 지우기.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextField && textField.text == "TOP" {
            textField.text = ""
        } else if textField == bottomTextField && textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    // 대문자로 변경하기.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var text = textField.text as NSString?
        text = text!.replacingCharacters(in: range, with: string) as NSString?
        textField.text = text?.uppercased
        return false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // return 키 눌렀을때
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 편집이 끝났을때 내용이 비어있을때
        if textField == self.topTextField && textField.text!.isEmpty {
            textField.text = "TOP";
        } else if textField == self.bottomTextField && textField.text!.isEmpty {
            textField.text = "BOTTOM";
        }
    }
}

extension MemePhotoEditingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fontData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoEditingFontCollectionReusableIdentifier, for: indexPath) as! MemePhotoEditingFontCollectionViewCell
        cell.largeFontLabel.font = UIFont(name: self.fontData[indexPath.row], size: 30)
        cell.smallFontLabel.text = fontData[indexPath.row]
        self.updateCell()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCellIndexPath = indexPath
        self.topTextField.font = UIFont(name: fontData[indexPath.row], size: 40)
        self.bottomTextField.font = UIFont(name: fontData[indexPath.row], size: 40)
        self.updateCell()
    }
    
    // Selected Cell 효과
    func updateCell(){
        // 나머지는 기본 사항.
        for i in 0...fontData.count {
            if let selectedCell = self.fontCollectionView.cellForItem(at: IndexPath.init(row: i, section: 0)) {
                let cell = selectedCell as! MemePhotoEditingFontCollectionViewCell
                cell.largeFontLabel.layer.borderColor = self.themeColor.cgColor
                cell.largeFontLabel.layer.borderWidth = 0
                cell.smallFontLabel.textColor = UIColor.lightGray
            }
        }
        // 선택한 셀 효과 주기.
        if let indexPath = self.selectedCellIndexPath {
            if let selectedCell = self.fontCollectionView.cellForItem(at: indexPath) {
                let cell = selectedCell as! MemePhotoEditingFontCollectionViewCell
                cell.largeFontLabel.layer.borderWidth = 4
                cell.smallFontLabel.textColor = self.themeColor
            }
        }
    }
}
