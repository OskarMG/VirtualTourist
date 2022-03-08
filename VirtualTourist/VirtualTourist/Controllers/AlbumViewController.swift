//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 1/3/22.
//

import UIKit
import MapKit
import CoreData

class AlbumViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    static let identifier: String = "AlbumViewController"
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newAlbumBtn: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var pin: Pin!
    var photos = [Photo]()
    weak var dataController: DataController!
    

    // MARK: ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        zoomToPinLocation()
        processing(true)
        checkForAlbum()
    }
    
    
    /// Configure NavBar UI
    private func configureNavBar() {
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    /// Configure CollectionView
    private func configureCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout = self.createThreeColumnFlowLayout(in: self.view)
        }
    }
    
    func createThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let width                       = view.bounds.width
        let padding: CGFloat            = 12
        let minimunItemSpace: CGFloat   = 10
        let availableWidth              = width - (padding * 2) - (minimunItemSpace * 2)
        let itemWidth                   = availableWidth / 3
        
        let flowLayout                  = UICollectionViewFlowLayout()
        flowLayout.sectionInset         = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize             = CGSize(width: itemWidth, height: itemWidth + 40)
        
        return flowLayout
    }
    
    /// Configure MapView
    private func configureMapView() {
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
    }
    
    /// Empty Message
    func showEmptyAlbumMessage(_ flag: Bool) {
        DispatchQueue.main.async { self.noImageLabel.isHidden = !flag }
    }
    
    /// New album button state method
    func setNewAlbumButton(state flag: Bool) {
        newAlbumBtn.isEnabled = flag
    }
    
    /// Activity indicator state
    func processing(_ flag: Bool) {
        DispatchQueue.main.async {
            if flag { self.activityIndicator.startAnimating() }
            else { self.activityIndicator.stopAnimating() }
        }
    }
    
    /// Zoom to pin location
    private func zoomToPinLocation() {
        let mkCoordSpan   = MKCoordinateSpan(latitudeDelta: 1.5, longitudeDelta: 1.5)
        let coordinate    = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let mkCoordRegion = MKCoordinateRegion(center: coordinate, span: mkCoordSpan)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            DispatchQueue.main.async { self.mapView.setRegion(mkCoordRegion, animated: true) }
        }
    }
    
    /// Fetch local saved album
    func fetchPhotoCollectionFor(_ album: Album) {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "album == %@", album)
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            photos = result
            self.setNewAlbumButton(state: true)
            DispatchQueue.main.async { self.collectionView.reloadData() }
        }
        processing(false)
    }
    
    func deleteAlbum() {
        setNewAlbumButton(state: false)
        for photoToDelete in photos { dataController.viewContext.delete(photoToDelete) }
        
        do { try dataController.viewContext.save()
        } catch { print("error saving the context: \(error.localizedDescription)") }
        
        photos = []
        DispatchQueue.main.async { self.collectionView.reloadData() }
    }
    
    /// Check for existing album
    func checkForAlbum() {
        guard let album = pin.album else {
            processing(false)
            showEmptyAlbumMessage(true)
            return
        }

        if album.isEmpty {
            deleteAlbum()
            showEmptyAlbumMessage(true)
            setNewAlbumButton(state: false)
            NetworkManager.shared.downloadAlbumFor(lat: pin.latitude, long: pin.longitude, completion: handleAlbumResponse)
        } else { fetchPhotoCollectionFor(album) }
    }
    
    
    /// Download album handle response
    func handleAlbumResponse(photoResponse: FKRAlbumResponse?, error: VTError?) {
        if let error = error { presentAlert(title: "Something went wrong", message: error.rawValue) }
        else {
            guard let album = photoResponse else { return }
            let list = album.photo
            
            pin.album?.totalPages = Int16(album.pages)
            if album.photo.isEmpty {
                self.showEmptyAlbumMessage(true)
            } else {
                for photoResponse in list {
                    let photo = Photo(context: dataController.viewContext)
                    photo.id  = photoResponse.id
                    photo.url = photoResponse.url
                    photo.album = self.pin.album
                    self.photos.append(photo)
                }
                
                self.collectionView.reloadData()        
                do { try dataController.viewContext.save()
                } catch { print(error.localizedDescription) }
            }
        }
        
        processing(false)
        setNewAlbumButton(state: true)
        showEmptyAlbumMessage(photos.count == 0)
    }
    
    func randomPage() -> Int {
        guard let album = pin.album else { return 1 }
        let totalPages:  Int = Int(album.totalPages)
        let currentPage: Int = Int(album.page)
        var randomPage:  Int = 1

        repeat { randomPage = Int.random(in: 1..<totalPages)
        } while randomPage == currentPage
        
        return randomPage
    }
    

    
    /// Fetch new collection method
    @IBAction func onNewAlbumTap(_ sender: UIBarButtonItem) {
        processing(true)
        deleteAlbum()

        guard let album = pin.album else { return }
        let randomPage = randomPage()
        album.page = Int16(randomPage)
        NetworkManager.shared.downloadAlbumFor(lat: pin.latitude, long: pin.longitude, page: randomPage, completion: handleAlbumResponse)
    }
    

}

//MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return photos.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        cell.configureCell(with: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = photos[indexPath.row]
        dataController.viewContext.delete(photoToDelete)
        
        do {
            try dataController.viewContext.save()
            photos.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
        } catch { print("Error while saving context: \(error.localizedDescription)") }
    }
}

