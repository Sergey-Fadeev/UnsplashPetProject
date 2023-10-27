//
//  APIUserResponse.swift
//  UnsplashPetProject
//
//  Created by Sergey on 27.10.2023.
//

struct APIUserResponse: Codable {
  
  let id: String
  let updatedAt: String
  let username, name, firstName: String
  let lastName, twitterUsername: String?
  let portfolioURL: String?
  let bio: String?
  let location: String?
  let profileImage: APIProfileImageResponse
  let instagramUsername: String?
  let totalCollections, totalLikes, totalPhotos: Int
  let acceptedTos, forHire: Bool
  
  enum CodingKeys: String, CodingKey {
    case id
    case updatedAt = "updated_at"
    case username, name
    case firstName = "first_name"
    case lastName = "last_name"
    case twitterUsername = "twitter_username"
    case portfolioURL = "portfolio_url"
    case bio, location
    case profileImage = "profile_image"
    case instagramUsername = "instagram_username"
    case totalCollections = "total_collections"
    case totalLikes = "total_likes"
    case totalPhotos = "total_photos"
    case acceptedTos = "accepted_tos"
    case forHire = "for_hire"
  }
  
  var asDomain: DomainUserResponse {
    DomainUserResponse(
      id: id,
      updatedAt: updatedAt,
      username: username,
      name: name,
      firstName: firstName,
      lastName: lastName,
      twitterUsername: twitterUsername,
      portfolioURL: portfolioURL,
      bio: bio,
      location: location,
      profileImage: profileImage.asDomain,
      instagramUsername: instagramUsername,
      totalCollections: totalCollections,
      totalLikes: totalLikes,
      totalPhotos: totalPhotos,
      acceptedTos: acceptedTos,
      forHire: forHire
    )
  }
  
}
