//
//  CustomError.swift
//  UnsplashPetProject
//
//  Created by Sergey on 27.10.2023.
//

import Foundation

extension NSError {
  
  enum APIError: Error {
    
      case invalidResponse
      case invalidData
    
  }
  
}
