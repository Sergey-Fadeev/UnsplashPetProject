//
//  ImageCellViewModel.swift
//  UnsplashPetProject
//
//  Created by Sergey on 31.10.2023.
//

import Combine
import UIKit

class ImageCellViewModel: ObservableObject {
  
  @Published var image: UIImage?
  private var cancellables = Set<AnyCancellable>()
  
  private var imageUrlString: String
  private var networkService = NetworkService.shared
  
  init(imageUrlString: String) {
    self.imageUrlString = imageUrlString
  }
  
  func loadImage() {
    if let cachedImage = ImageCache.shared.getImage(for: imageUrlString) {
      image = cachedImage
    } else {
      networkService.loadImage(urlString: imageUrlString)
        .flatMap { [weak self] imageData -> AnyPublisher<UIImage, Never> in
          guard let self = self, let loadedImage = UIImage(data: imageData) else {
            return Empty(completeImmediately: false).eraseToAnyPublisher()
          }
          
          ImageCache.shared.setImage(loadedImage, for: self.imageUrlString)
          
          return Just(loadedImage)
            .eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .sink(
          receiveCompletion: { error in
            print("\(error)")
          },
          receiveValue: { [weak self] loadedImage in
            self?.image = loadedImage
          }
        )
        .store(in: &cancellables)
    }
  }
  
}
