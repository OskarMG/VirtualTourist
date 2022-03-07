//
//  FKRAlbumResponse.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 7/3/22.
//

import Foundation


struct FKRAlbumResponse: Codable {
    let page:    Int
    let pages:   Int
    let perpage: Int
    let total:   Int
    let photo: [FKRPhoto]
}
