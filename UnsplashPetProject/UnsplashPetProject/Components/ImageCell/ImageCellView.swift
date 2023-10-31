//
//  ImageCellView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 31.10.2023.
//

import SwiftUI
import Combine

struct ImageCellView: View {
  
  @State var image: UIImage?
  @State private var cancellables = Set<AnyCancellable>()
  
  @ObservedObject var viewModel: ImageCellViewModel
  
  var body: some View {
    if let image = viewModel.image {
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
          viewModel.loadImage()
        }
    }
  }
  
}

//#Preview {
//    ImageCellView()
//}
