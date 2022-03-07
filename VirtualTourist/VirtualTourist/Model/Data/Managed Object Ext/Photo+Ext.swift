//
//  Photo+Ext.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 5/3/22.
//

import Foundation
import CoreData

extension Photo {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
}
