//
//  FlickrResponse.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 3/3/22.
//

import Foundation


struct FlickrResponse: Codable {
    
    let photos: FKRAlbumResponse
    let stat: String
    
}
