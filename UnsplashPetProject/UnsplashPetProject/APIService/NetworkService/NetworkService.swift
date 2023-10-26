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
  
  func loadImages(page: Int, username: String? = nil) -> AnyPublisher<[APIImageResponse], Error> {
    let apiTarget = DefaulAPITarget.loadImages(
      LoadPageRequest(
        page: page,
        clientId: "Ad3y-sB1XiKe0Q0nJITelHrKFrDbGr1h5iUpjJadDAE",
        username: username
      )
    )
    
    let url = URL(string: apiTarget.fullUrlString)!
    
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
      .decode(type: [APIImageResponse].self, decoder: JSONDecoder())
      .map { response in
        guard !response.isEmpty else {
          return []
        }
        
        return response
      }
      .eraseToAnyPublisher()
  }
  
  func loadImages(responseArray: [APIImageResponse]) -> AnyPublisher<[ImageResponseDomain], Error> {
    // Создаем массив из сетевых запросов
    let imageLoaders = responseArray.enumerated().map { index, imageRsponse -> AnyPublisher<ImageResponseDomain?, Never> in
      guard let url = URL(string: imageRsponse.imageUrls.small) else {
        return Empty(completeImmediately: false).eraseToAnyPublisher()
      }
      
      return URLSession.shared.dataTaskPublisher(for: url)
        .map { data, _ -> ImageResponseDomain? in
          guard let uiImage = UIImage(data: data) else {
            return nil
          }
          
          return ImageResponseDomain(image: uiImage, imageAPIResponse: responseArray[index])
          
        }
        .catch { _ in Just(nil) }
        .eraseToAnyPublisher()
    }
    
    // Комбинируем все сетевые запросы в один массив картинок
    return Publishers.Sequence(sequence: imageLoaders)
      .flatMap { $0 }
      .compactMap { $0 }
      .collect()
      .eraseToAnyPublisher()
  }
  
  func loadImage(urlString: String) -> AnyPublisher<Data, Error> {
    guard let url = URL(string: urlString) else {
      return Empty(completeImmediately: false).eraseToAnyPublisher()
    }
    
    return URLSession.shared.dataTaskPublisher(for: url)
      .tryMap { data, response -> Data in
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
          throw NSError(domain: httpResponse.debugDescription, code: httpResponse.statusCode)
        }
        
        return data
      }
      .eraseToAnyPublisher()
  }
  
}

enum APIError: Error {
  
    case invalidResponse
    case invalidData
  
}

struct ImageResponseDomain: Identifiable {
  
  let image: UIImage
  let imageAPIResponse: APIImageResponse
  
  var id: String {
    imageAPIResponse.id
  }
  
}
