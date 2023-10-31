//
//  ImageCellView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 31.10.2023.
//

import SwiftUI
import Combine

struct ImageCellView: View {
  
  var imageUrlString: String
  
  @State var image: UIImage?
  
  var body: some View {
    if let image = image {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .cornerRadius(12)
    } else {
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.gray)
        .opacity(0.5)
        .overlay {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
        }
        .onAppear {
          loadImage()
        }
    }
  }
  
  private func loadImage() {
    if let cachedImage = ImageCache.shared.getImage(for: imageUrlString) {
      image = cachedImage
    } else {
      guard let imageUrl = URL(string: imageUrlString) else {
        return
      }
      
      URLSession.shared.dataTask(with: imageUrl) { data, response, error in
        guard let data = data, let loadedImage = UIImage(data: data) else { return }
        
        ImageCache.shared.setImage(loadedImage, for: imageUrlString)
        DispatchQueue.main.async {
          image = loadedImage
        }
      }.resume()
    }
  }
  
}

//#Preview {
//    ImageCellView()
//}
