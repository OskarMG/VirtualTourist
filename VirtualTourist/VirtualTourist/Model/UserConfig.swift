//
//  UserConfig.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 2/3/22.
//

import UIKit
import MapKit


struct MKCoordinate: Codable {
    let latitude:  CLLocationDegrees
    let longitude: CLLocationDegrees
}

struct MKSpan: Codable {
    let latitudeDelta:  CLLocationDegrees
    let longitudeDelta: CLLocationDegrees
}

struct UserConfig: Codable {
    
    var span: MKSpan
    var coordinate: MKCoordinate
    
}
