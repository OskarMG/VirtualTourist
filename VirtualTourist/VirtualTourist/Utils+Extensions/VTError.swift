//
//  VTError.swift
//  VirtualTourist
//
//  Created by Oscar Martínez Germán on 2/3/22.
//

import Foundation


enum VTError: String, Error {
    
    /// File Manager Errors
    case notUserConfig  = "User has not previews settings."
    case couldNotDecodeUserConfig = "Could not decode User configurations."
    
    
    /// Network Errors
    case unableToComplete  = "Unable to complete your request. Please check your internet connection."
    case badCredentials    = "Unable to login, check your email or password. 😬"
    case invalidData       = "Data received from the server was invalid. Please try again."
    case invalidResponse   = "Invalid response from the server. Please try again."
    case unableToSubmitRequest = "Unable to submit request."
    
    
    /// CoreData Errors
    case couldNotSaveContext = "CoreData could not save context."
}
