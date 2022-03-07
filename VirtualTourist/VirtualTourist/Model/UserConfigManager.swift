//
//  UserConfigManager.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 2/3/22.
//

import Foundation
import MapKit

enum UserConfigManager {
   
    static private let defaults = UserDefaults.standard
    
    enum Keys: String {
        case userConfig
    }
    
    static func getUserConfig (completed: @escaping(Result<UserConfig, VTError>) -> Void) {
        guard let userConfigData = defaults.object(forKey: Keys.userConfig.rawValue) as? Data else {
            completed(.failure(.notUserConfig))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let userConfig = try decoder.decode(UserConfig.self, from: userConfigData)
            completed(.success(userConfig))
        } catch { completed(.failure(.couldNotDecodeUserConfig)) }
    }
    
    static func save(userConfig: UserConfig) {
        do {
            let encoder = JSONEncoder()
            let encoderUserConfig = try encoder.encode(userConfig)
            defaults.set(encoderUserConfig, forKey: Keys.userConfig.rawValue)
        } catch { debugPrint(error.localizedDescription) }
    }
}
