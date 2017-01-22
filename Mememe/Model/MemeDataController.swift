//
//  MemeDataController.swift
//  MemeMe
//
//  Created by 최유태 on 2017. 1. 22..
//  Copyright © 2017년 YutaeChoi. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// 참고 - Apple Guide Line 을 Swift 3.0.2 Version 으로 수정

class MemeDataController: NSObject {
    var managedObjectContext: NSManagedObjectContext
    override init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        DispatchQueue.global(qos: .background).async {
            let urls = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
            let docURL = urls[urls.endIndex-1]
            let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
            do{
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch{
                fatalError("Error migrating store: \(error)")
            }
        }
    }
}
