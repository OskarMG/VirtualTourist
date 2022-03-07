//
//  FKRPhoto.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 3/3/22.
//

import Foundation

struct FKRPhoto: Codable {
    
    let id:    String
    let title: String
    let url:   String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url = "url_m"
    }
    
}
