//
//  APITarget.swift
//  UnsplashPetProject
//
//  Created by Sergey on 26.10.2023.
//

import Foundation

enum DefaulAPITarget {
  
  case loadImages(LoadPageRequest)
  
  var fullUrlString: String {
    switch self {
    case let .loadImages(request): return "\(Constants.baseURL)/\(request.path)"
    }
  }
  
}
