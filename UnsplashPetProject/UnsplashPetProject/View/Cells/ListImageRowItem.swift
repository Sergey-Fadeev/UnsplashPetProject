//
//  ListImageRowItem.swift
//  UnsplashPetProject
//
//  Created by Sergey on 10.10.2023.
//

import SwiftUI
import Combine

struct ListImageRowItem: View {
  
  @Binding var item: APIImageResponse
  @Binding var isLoading: Bool
  
    var body: some View {
//      AsyncImage(url: URL(string: item.imageUrls.small))
//        .frame(width: 50, height: 50)
      
      print("url - \(item.imageUrls.regular)")
      
      
      return AsyncImage(
        url: URL(string: item.imageUrls.regular),
        content: { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        },
        placeholder: {
          ProgressView()
        }
      )
      .onAppear {
        isLoading = false
    }
      
      
      
      
//      AsyncImage(
//        url: URL(string: item.imageUrls.small),
//        content: { image in
//          image.resizable()
//            .scaledToFit()
//            .frame(width: geo.size.width * 0.8, height: 300)
//        },
//        placeholder: {
//          ProgressView()
//        }
//      )
    }
  
}
