//
//  DomainUserResponse.swift
//  UnsplashPetProject
//
//  Created by Sergey on 27.10.2023.
//

struct DomainUserResponse {
  
  let id: String
  let updatedAt: String
  let username, name, firstName: String
  let lastName, twitterUsername: String?
  let portfolioURL: String?
  let bio: String?
  let location: String?
  let profileImage: DomainProfileImageResponse
  let instagramUsername: String?
  let totalCollections, totalLikes, totalPhotos: Int
  let acceptedTos, forHire: Bool
  
}
