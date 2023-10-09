//
//  APIUnsplashResponse.swift
//  UnsplashPetProject
//
//  Created by Sergey on 09.10.2023.
//

struct APIUnsplashResponse: Codable {
  
    let items: [APIUnsplashItem]
    let hasMorePages: Bool
  
}

// MARK: - Item
struct APIUnsplashItem: Codable, Identifiable {
  
    let id, label: String
  
}
