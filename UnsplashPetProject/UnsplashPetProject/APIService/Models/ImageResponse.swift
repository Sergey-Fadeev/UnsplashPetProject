//
//  ImageResponse.swift
//  UnsplashPetProject
//
//  Created by Sergey on 09.10.2023.
//

struct APIImageResponse: Codable {
  
    let id, slug: String
    let createdAt, updatedAt: String
    let promotedAt: String?
    let width, height: Int
    let color, blurHash: String
    let description: String?
    let altDescription: String?
    let imageUrls: APIImageUrlsResponse
    let links: APIImageLinksResponse
    let likes: Int
    let likedByUser: Bool
    let sponsorship: APISponsorshipResponse?
    let topicSubmissions: APITopicSubmissionsResponse
    let user: APIUserResponse?

    enum CodingKeys: String, CodingKey {
        case id, slug
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case promotedAt = "promoted_at"
        case width, height, color
        case blurHash = "blur_hash"
        case description
        case altDescription = "alt_description"
        case imageUrls = "urls"
        case links, likes
        case likedByUser = "liked_by_user"
        case sponsorship
        case topicSubmissions = "topic_submissions"
        case user
    }
  
}

struct APIImageLinksResponse: Codable {
  
    let linksSelf, html, download, downloadLocation: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, download
        case downloadLocation = "download_location"
    }
  
}

struct APISponsorshipResponse: Codable {
  
    let impressionUrls: [String]
    let tagline: String
    let taglineURL: String
    let sponsor: APIUserResponse

    enum CodingKeys: String, CodingKey {
        case impressionUrls = "impression_urls"
        case tagline
        case taglineURL = "tagline_url"
        case sponsor
    }
  
}

struct APIUserResponse: Codable {
  
    let id: String
    let updatedAt: String
    let username, name, firstName: String
    let lastName, twitterUsername: String?
    let portfolioURL: String?
    let bio: String?
    let location: String?
    let links: APIUserLinksResponse
    let profileImage: APIProfileImageResponse
    let instagramUsername: String?
    let totalCollections, totalLikes, totalPhotos: Int
    let acceptedTos, forHire: Bool
    let social: APISocialResponse

    enum CodingKeys: String, CodingKey {
        case id
        case updatedAt = "updated_at"
        case username, name
        case firstName = "first_name"
        case lastName = "last_name"
        case twitterUsername = "twitter_username"
        case portfolioURL = "portfolio_url"
        case bio, location, links
        case profileImage = "profile_image"
        case instagramUsername = "instagram_username"
        case totalCollections = "total_collections"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case acceptedTos = "accepted_tos"
        case forHire = "for_hire"
        case social
    }
  
}

struct APIUserLinksResponse: Codable {
  
    let linksSelf, html, photos, likes: String
    let portfolio, following, followers: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, photos, likes, portfolio, following, followers
    }
  
}

struct APIProfileImageResponse: Codable {
  
    let small, medium, large: String
  
}

struct APISocialResponse: Codable {
  
    let instagramUsername: String?
    let portfolioURL: String?
    let twitterUsername: String?

    enum CodingKeys: String, CodingKey {
        case instagramUsername = "instagram_username"
        case portfolioURL = "portfolio_url"
        case twitterUsername = "twitter_username"
    }
  
}

struct APITopicSubmissionsResponse: Codable {
  
    let nature: APINatureResponse?
    let wallpapers, monochromatic, texturesPatterns, spirituality: APIFashionBeautyResponse?
    let fashionBeauty: APIFashionBeautyResponse?

    enum CodingKeys: String, CodingKey {
        case nature, wallpapers, monochromatic
        case texturesPatterns = "textures-patterns"
        case spirituality
        case fashionBeauty = "fashion-beauty"
    }
  
}

struct APIFashionBeautyResponse: Codable {
  
    let status: String
  
}

struct APINatureResponse: Codable {
  
    let status: String
    let approvedOn: String?

    enum CodingKeys: String, CodingKey {
        case status
        case approvedOn = "approved_on"
    }
  
}

struct APIImageUrlsResponse: Codable {
  
    let raw, full, regular, small: String
    let thumb, smallS3: String

    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
        case smallS3 = "small_s3"
    }
  
}
