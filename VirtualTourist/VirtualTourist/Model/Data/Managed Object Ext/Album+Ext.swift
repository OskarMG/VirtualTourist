//
//  Album+Ext.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 5/3/22.
//

import Foundation
import CoreData

extension Album {
    
    //MARK: Properties
    var isEmpty: Bool { self.photos?.count ?? 0 == 0 }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
