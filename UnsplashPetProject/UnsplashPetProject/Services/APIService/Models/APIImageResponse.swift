//
//  APIImageResponse.swift
//  UnsplashPetProject
//
//  Created by Sergey on 09.10.2023.
//

struct APIImageResponse: Codable {
  
  let id: String
  let createdAt: String
  let width, height: Int
  let description: String?
  let altDescription: String?
  let imageUrls: APIImageUrlsResponse
  let likes: Int
  let user: APIUserResponse?
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case width, height
    case description
    case altDescription = "alt_description"
    case imageUrls = "urls"
    case likes
    case user
  }
  
  var asDomain: DomainImageResponse {
    DomainImageResponse(
      id: id,
      createdAt: createdAt,
      width: width,
      height: height,
      description: description,
      altDescription: altDescription,
      imageUrls: imageUrls.asDomain,
      likes: likes,
      user: user?.asDomain
    )
  }
  
}
