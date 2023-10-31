//
//  APIProfileImageResponse.swift
//  UnsplashPetProject
//
//  Created by Sergey on 27.10.2023.
//

struct APIProfileImageResponse: Codable {
  
  let small: String
  let medium: String
  let large: String
  
  var asDomain: DomainProfileImageResponse {
    DomainProfileImageResponse(
      small: small,
      medium: medium,
      large: large
    )
  }
  
}
