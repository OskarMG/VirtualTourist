//
//  Pin+Ext.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 5/3/22.
//

import Foundation
import CoreData
import UIKit

extension Pin {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        album = Album(context: managedObjectContext!)
        creationDate = Date()
    }
    
}
