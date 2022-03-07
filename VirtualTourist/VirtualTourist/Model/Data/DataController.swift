//
//  DataController.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 5/3/22.
//

import Foundation
import CoreData

class DataController {
    
    //MARK: Properties
    static let modelName = "VirtualTourist"
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext { return persistentContainer.viewContext }
    
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    /// Load Store
    func load(completion: (()->Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDesc, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
