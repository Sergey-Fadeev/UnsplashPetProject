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
  
  @Published var itemsResponse: APIUnsplashResponse?
  
  private init() { }
  
  func loadMoreContent(page: Int) async -> AnyPublisher<APIUnsplashResponse?, Error> {
    let url = URL(string: "https://s3.eu-west-2.amazonaws.com/com.donnywals.misc/feed-\(page).json")!
    
    return URLSession.shared.dataTaskPublisher(for: url)
      .subscribe(on: DispatchQueue.global())
      .tryMap { data, response -> Data in
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
          throw NSError(domain: httpResponse.debugDescription, code: httpResponse.statusCode)
        }
        
        return data
      }
      .decode(type: APIUnsplashResponse.self, decoder: JSONDecoder())
      .receive(on: DispatchQueue.main)
      .map { response in
        response
      }
      .eraseToAnyPublisher()
  }
  
}

enum APIError: Error {
  
    case invalidResponse
    case invalidData
  
}
