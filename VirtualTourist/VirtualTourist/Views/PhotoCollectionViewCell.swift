//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 1/3/22.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    static let identifier = "PhotoCollectionViewCell"
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func configureImageViewUI() {
        DispatchQueue.main.async {
            self.photoImageView.image = UIImage(named: "place-holder-image")
            self.photoImageView.clipsToBounds = true
            self.photoImageView.layer.cornerRadius = 5
        }
    }
    
    //MARK: - CollectionView Methods
    func configureCell(with photo: Photo) {
        configureImageViewUI()
        guard let url = photo.url else { return }
        
        NetworkManager.shared.downloadImage(strUrl: url) { [weak self] image in
            guard let self = self, let image = image else { return }
            self.photoImageView.image = image
            photo.image = image.jpegData(compressionQuality: 1)
        }
    }
    
}
