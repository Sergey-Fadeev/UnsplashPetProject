//
//  NetworkService.swift
//  UnsplashPetProject
//
//  Created by Sergey on 09.10.2023.
//

import SwiftUI
import Combine

class NetworkService: ObservableObject {
  
  static let shared = NetworkService()
  
  private init() { }
  
  func loadImages(page: Int, username: String? = nil) -> AnyPublisher<[DomainImageResponse], Error> {
    let apiTarget = DefaulAPITarget.loadImages(
      LoadPageRequest(page: page, username: username)
    )
    
    let url = URL(string: apiTarget.fullUrlString)!
    
    return URLSession.shared.dataTaskPublisher(for: url)
      .subscribe(on: DispatchQueue.global())
      .tryMap { data, response -> Data in
        guard let httpResponse = response as? HTTPURLResponse else {
          throw NSError.APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
          throw NSError(domain: httpResponse.debugDescription, code: httpResponse.statusCode)
        }
        
        return data
      }
      .decode(type: [APIImageResponse].self, decoder: JSONDecoder())
      .map { response in
        guard !response.isEmpty else {
          return []
        }
        
        return response.map { $0.asDomain }
      }
      .eraseToAnyPublisher()
  }
  
  func loadImage(urlString: String) -> AnyPublisher<Data, Error> {
    guard let url = URL(string: urlString) else {
      return Empty(completeImmediately: false).eraseToAnyPublisher()
    }
    
    return URLSession.shared.dataTaskPublisher(for: url)
      .tryMap { data, response -> Data in
        guard let httpResponse = response as? HTTPURLResponse else {
          throw NSError.APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
          throw NSError(domain: httpResponse.debugDescription, code: httpResponse.statusCode)
        }
        
        return data
      }
      .eraseToAnyPublisher()
  }
  
}
