//
//  NetworkManager.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 2/3/22.
//

import Foundation
import UIKit


class NetworkManager {
    
    // MARK: Properties
    static let shared = NetworkManager()
    static private let apiKey = "[PLACE YOUR API KEY HERE]"
    
    enum Endpoint {
        static let base = "https://www.flickr.com/services/rest/"
        static let numberOfPhotos = 40
         
        /// Get Photos For Lat, Long, Page
        case getPhotosFor(Double, Double, Int)
         
        var stringValue: String {
            switch self {
                case .getPhotosFor(let lat, let long, let page):
                    return Endpoint.base + "?method=flickr.photos.getRecent&api_key=" + apiKey + "&nojsoncallback=1&format=json&per_page=\(Endpoint.numberOfPhotos)&extras=url_m" + "&lat=" + String(lat) + "&lon=" + String(long) + "&page=" + String(page)
            }
        }
        
        var url: URL { return URL(string: stringValue)! }
    }
    
    private init() {}
    
    
    // MARK: API Methods
    private func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping((Result<ResponseType, VTError>)->Void)) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error { completion(.failure(.unableToComplete)); return }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse)); return
            }
            
            guard let data = data else { completion(.failure(.invalidData)); return }
            let decoder = JSONDecoder()

//            let str = String(decoding: data, as: UTF8.self)
//            print("response: ", str)
            
            do {
                let responseObjc = try decoder.decode(responseType.self, from: data)
                completion(.success(responseObjc))
            } catch { completion(.failure(.unableToComplete)) }
        }.resume()
    }
    
    
    
    func downloadAlbumFor(lat: Double, long: Double, page: Int = 1, completion: @escaping((FKRAlbumResponse?, VTError?)->Void)) {
        taskForGetRequest(url: Endpoint.getPhotosFor(lat, long, page).url, responseType: FlickrResponse.self) { [weak self] result in
            guard let _ = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .failure(let error): completion(nil, error)
                case .success(let fkrResponse): completion(fkrResponse.photos, nil)
                }
            }
        }
    }
    
    func downloadImage(strUrl: String, completion: @escaping((UIImage?)->Void)) {
        guard let url = URL(string: strUrl) else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
              let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
              let data = data else {
                  DispatchQueue.main.async { completion(nil) }; return
              }
            DispatchQueue.main.async { completion(UIImage(data: data)) }
        }.resume()
    }
    
}
