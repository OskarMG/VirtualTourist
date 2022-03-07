//
//  Extensions.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 5/3/22.
//

import UIKit

//MARK: - View Controller Extension
extension UIViewController {
    
    func presentAlert(title: String = "", message: String = "") {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alertVC.dismiss(animated: true)
            }
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true)
        }
    }
    
}
