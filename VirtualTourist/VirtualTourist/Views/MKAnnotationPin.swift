//
//  MKAnnotationPin.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 5/3/22.
//

import MapKit

class MKAnnotationPin: NSObject, MKAnnotation {
    
    //MARK: Properties
    static let identifier = "MKAnnotationPin"
    var pin: Pin
    var coordinate: CLLocationCoordinate2D
    
    init(pin: Pin) {
        self.pin = pin
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.latitude)
        super.init()
    }
    
}
