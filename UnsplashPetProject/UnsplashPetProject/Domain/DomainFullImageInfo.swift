//
//  DomainFullImageInfo.swift
//  UnsplashPetProject
//
//  Created by Sergey on 27.10.2023.
//

import Foundation

struct DomainFullInfoImage: Identifiable {
  
  let imageData: Data
  let imageAPIResponse: DomainImageResponse
  
  var id: String {
    imageAPIResponse.id
  }
  
}
