//
//  LocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 1/3/22.
//

import UIKit
import MapKit
import CoreData

class LocationsMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    
    var pins: [Pin]!
    weak var dataController: DataController!
    
    
    // MARK: ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomToLastPosition()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        configureMapView()
    }
    
    
    /// Configure ViewController UI
    private func configureUI() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    /// Configure MapView
    private func configureMapView() {
        mapView.delegate = self
        let onLongTap = UILongPressGestureRecognizer(target: self, action: #selector(handleGestures(gestureRecognizer:)))
        onLongTap.delaysTouchesEnded = true
        onLongTap.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(onLongTap)
    }
    
    private func mapViewContainsCoordinates( _ coordinate: CLLocationCoordinate2D) -> Bool {
        return mapView.annotations.contains { $0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude }
    }
    
    private func saveMapView(lat: CLLocationDegrees, long: CLLocationDegrees, span: MKCoordinateSpan) {
        let coord  = MKCoordinate(latitude: lat, longitude: long)
        let mkSpan = MKSpan(latitudeDelta: span.latitudeDelta, longitudeDelta: span.longitudeDelta)
        UserConfigManager.save(userConfig: UserConfig(span: mkSpan, coordinate: coord))
    }
    
    private func zoomToLastPosition() {
        UserConfigManager.getUserConfig { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let userConfig):
                    let mkCoordSpan = MKCoordinateSpan(latitudeDelta: userConfig.span.latitudeDelta, longitudeDelta: userConfig.span.longitudeDelta)
                    let coordinate = CLLocationCoordinate2D(latitude: userConfig.coordinate.latitude, longitude: userConfig.coordinate.longitude)
                    self.mapView.setRegion(MKCoordinateRegion(center: coordinate, span: mkCoordSpan), animated: true)
                    case.failure: break
                }
            }
        }
    }
    
    
    ///Fetch Data From Store
    func fetchData() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            self.updateMapViewPins()
        }
    }
    
    ///Update MapView Pins
    func updateMapViewPins(){
        if !pins.isEmpty {
            var annotations = [MKAnnotation]()
            for pin in pins {
                let annotation = MKAnnotationPin(pin: pin)
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                annotations.append(annotation)
            }
            DispatchQueue.main.async { self.mapView.addAnnotations(annotations) }
        }
    }
    
    /// Handle MapView Gestures
    @objc func handleGestures(gestureRecognizer: UIGestureRecognizer) {
        let touchLocation = gestureRecognizer.location(in: mapView)
        let coordinate    = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        if let longPress = gestureRecognizer as? UILongPressGestureRecognizer {
            if longPress.state == .began { addPin(with: coordinate) }
        }
    }
    
    /// Prepare for segue to AlbumViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let albumViewController = segue.destination as! AlbumViewController
        albumViewController.pin = sender as? Pin
        albumViewController.dataController = dataController
    }
    

}


// MARK: - MKMapViewDelegate
extension LocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapView(lat: mapView.region.center.latitude, long: mapView.region.center.longitude, span: mapView.region.span)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKAnnotationPin else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKAnnotationPin.identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKAnnotationPin.identifier)
            annotationView!.canShowCallout = false
        } else { annotationView!.annotation = annotation }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedPin = view.annotation as! MKAnnotationPin
        performSegue(withIdentifier: AlbumViewController.identifier, sender: selectedPin.pin)
    }
    
    func addPin(with coordinate: CLLocationCoordinate2D) {
        if !mapViewContainsCoordinates(coordinate) {
            let pin       = Pin(context: dataController.viewContext)
            pin.latitude  = coordinate.latitude
            pin.longitude = coordinate.longitude
            
            let annotation = MKAnnotationPin(pin: pin)
            annotation.coordinate = coordinate
            
            do {
                try dataController.viewContext.save()
                pins.append(pin)
                mapView.addAnnotation(annotation)
            } catch { presentAlert(title: VTError.couldNotSaveContext.rawValue, message: error.localizedDescription) }
        }
    }
}


