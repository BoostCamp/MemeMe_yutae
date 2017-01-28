//
//  PhotoEditingViewController.swift
//  MemeMeEffect
//
//  Created by 최유태 on 2017. 1. 24..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//
// 기존 Editor View 와 차이점 있습니다 !
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
    
    // Singleton
    let userDefaults:UserDefaults = UserDefaults.standard
    
    let fontData = Constants.fontsAvailable
    // Defalut font Name 값.
    var fontDefaultName:String?
    var selectedCellIndexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fontCollectionView.delegate = self
        self.fontCollectionView.dataSource = self
        self.fontButton.layer.cornerRadius = self.fontButton.frame.height / 2
        self.topTextField.keyboardType = .asciiCapable
        self.bottomTextField.keyboardType = .asciiCapable
    }
    override func viewDidAppear(_ animated: Bool) {
        // view Did Appear 완료 된 이후에 UI Setup
        super.viewDidAppear(animated)
        self.setupEditor()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // View 사라지려 할 때 Observer 제거
        self.unsubscribeFromKeyboardNotifications()
        /*
         self.fontData.count 까지 범위 이므로 selectedCellIndexPath 존재하면
         fontData[indexPath.row] 값 존재
         UserDefaults에  기록
         */
        if let indexPath = selectedCellIndexPath {
            self.userDefaults.setValue(self.fontData[indexPath.row], forKey: Constants.UserDefaultsKey.fontName)
            self.userDefaults.synchronize()
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    private func setupEditor() {
        // Main Thread 로 UI 변경, 안하면 변경되는데 딜레이가 존재.
        DispatchQueue.main.async {
            // Add Observer KeyboardNotifications
            self.subscribeToKeyboardNotifications()
            // Setup Font Collection
            self.fontCollectionView.isHidden = true
            self.fontDefaultName = self.userDefaults.string(forKey: Constants.UserDefaultsKey.fontName)
            // Optional Binding
            if let fontName = self.fontDefaultName {
                if let index = self.fontData.index(of: fontName) {
                    self.selectedCellIndexPath = IndexPath.init(row: index, section: 0)
                }
            }
            // Setup Text Fields
            self.setupTextFields([self.topTextField, self.bottomTextField])
        }
    }
    
    func setupTextFields(_ textFields: [UITextField]) {
        for textField in textFields {
            textField.defaultTextAttributes = Constants.MemeDefaultsValue.textAttributes
            // Optional Binding
            if let fontName = self.fontDefaultName{
                textField.font = UIFont.init(name: fontName, size: 40.0)
            }
            textField.textAlignment = NSTextAlignment.center
            textField.delegate = self;
            switch textField {
            case self.topTextField:
                self.topTextField.text = Constants.MemeDefaultsValue.topTextFieldText
            case self.bottomTextField:
                self.bottomTextField.text = Constants.MemeDefaultsValue.bottomTextFieldText
            default:
                return
            }
        }
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
        // 변경된 Image 를 background Queue 에서 관리
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            if (self.input?.fullSizeImageURL) != nil {
                let memedImage = self.generateMemedImage()
                
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
            
            completionHandler(output)
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        return true
    }
    func cancelContentEditing() {
        
    }
    
    @IBAction func setFontAction(_ sender: Any) {
        self.fontCollectionView.isHidden = !self.fontCollectionView.isHidden
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
            // bottom Textfield 편집시 font button hide
            self.fontButton.isHidden = true
            view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
        self.fontButton.isHidden = false
    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        self.fontCollectionView.isHidden = true
        self.fontButton.isHidden = true
        // frame 대신 bounds 를 사용한 이유 - bounds 는 x,y 가 자신이 기준이 되기 때문 <-> frame 은 부모 View 기준
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
        if textField == self.topTextField && textField.text == Constants.MemeDefaultsValue.topTextFieldText {
            textField.text = ""
        } else if textField == self.bottomTextField && textField.text == Constants.MemeDefaultsValue.bottomTextFieldText {
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
        if let textFieldIsEmpty = textField.text?.isEmpty {
            if textFieldIsEmpty {
                if textField == self.topTextField {
                    textField.text = Constants.MemeDefaultsValue.topTextFieldText
                } else if textField == self.bottomTextField {
                    textField.text = Constants.MemeDefaultsValue.bottomTextFieldText
                }
            }
        }
    }
}

extension MemePhotoEditingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fontData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifier.edtingFontCollectionViewCell, for: indexPath) as! MemePhotoEditingFontCollectionViewCell
        cell.largeFontLabel.font = UIFont(name: self.fontData[indexPath.row], size: 30)
        cell.smallFontLabel.text = fontData[indexPath.row]
        self.updateFontCell()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCellIndexPath = indexPath
        self.topTextField.font = UIFont(name: fontData[indexPath.row], size: 40)
        self.bottomTextField.font = UIFont(name: fontData[indexPath.row], size: 40)
        self.updateFontCell()
    }
    // Selected Cell 효과
    func updateFontCell(){
        // 나머지는 기본 사항.
        for i in 0...fontData.count {
            if let selectedCell = self.fontCollectionView.cellForItem(at: IndexPath.init(row: i, section: 0)), let cell = selectedCell as? MemePhotoEditingFontCollectionViewCell {
                cell.largeFontLabel.layer.borderWidth = 0
                cell.smallFontLabel.textColor = UIColor.lightGray
            }
        }
        // 선택한 셀 효과 주기.
        if let indexPath = self.selectedCellIndexPath {
            if let selectedCell = self.fontCollectionView.cellForItem(at: indexPath), let cell = selectedCell as? MemePhotoEditingFontCollectionViewCell {
                cell.largeFontLabel.layer.borderWidth = 4
                cell.smallFontLabel.textColor = UIColor.theme
            }
        }
    }
}
