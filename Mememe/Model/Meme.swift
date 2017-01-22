//
//  Meme.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//
import RealmSwift
import Foundation

// Model
class Meme : Object {
    dynamic var imagePath:String = ""
    dynamic var topText:String = ""
    dynamic var bottomText:String = ""
    dynamic var createAt = Date()
    
    func save(){
        guard let realm = try? Realm() else {
            // Error 핸들링
            print("ERROR!!!!!")
            return
        }
        do {
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}
