//
//  LoadPageRequest.swift
//  UnsplashPetProject
//
//  Created by Sergey on 26.10.2023.
//

struct LoadPageRequest {
  
  let page: Int
  let username: String?
  
  var path: String {
    guard let username = username else {
      return "/photos?page=\(page)&client_id=\(Constants.clientId)"
    }
    
    return "/users/\(username)/photos?page=\(page)&client_id=\(Constants.clientId)"
  }
  
}
