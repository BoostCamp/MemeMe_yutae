//
//  Meme.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//
import Foundation
import CoreLocation
import UIKit
// Model
struct Meme {
    var image:UIImage!
    var creationDate:Date!
    var isFavorite:Bool!
    var location:CLLocation?
}
