//
//  DomainImageResponse.swift
//  UnsplashPetProject
//
//  Created by Sergey on 27.10.2023.
//

struct DomainImageResponse {
  
  let id: String
  let createdAt: String
  let width, height: Int
  let description: String?
  let altDescription: String?
  let imageUrls: DomainImageUrlsResponse
  let likes: Int
  let user: DomainUserResponse?
  
}
