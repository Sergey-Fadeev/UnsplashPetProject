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
  
  func loadImages(page: Int) -> AnyPublisher<[APIImageResponse], Error> {
    let url = URL(string: "https://api.unsplash.com/photos?page=\(page)&client_id=Ad3y-sB1XiKe0Q0nJITelHrKFrDbGr1h5iUpjJadDAE")!
    
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
      .receive(on: DispatchQueue.main)
      .map { response in
        guard !response.isEmpty else {
          return []
        }
        
        return response
      }
      .eraseToAnyPublisher()
  }
  
  func loadImage(urlString: String) async -> AnyPublisher<Data, Error> {
    guard let url = URL(string: urlString) else {
      return Empty(completeImmediately: false).eraseToAnyPublisher()
    }
    
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
      .receive(on: DispatchQueue.main)
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
//      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
//      .sink { [weak self] images in
//        self?.images = images
//      }
//      .store(in: &cancellables)
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
