//
//  APIImageUrlsResponse.swift
//  UnsplashPetProject
//
//  Created by Sergey on 27.10.2023.
//

struct APIImageUrlsResponse: Codable {
  
  let raw, full, regular, small: String
  let thumb, smallS3: String
  
  enum CodingKeys: String, CodingKey {
    case raw, full, regular, small, thumb
    case smallS3 = "small_s3"
  }
  
  var asDomain : DomainImageUrlsResponse {
    DomainImageUrlsResponse(
      raw: raw,
      full: full,
      regular: regular,
      small: small,
      thumb: thumb,
      smallS3: smallS3
    )
  }
  
}
