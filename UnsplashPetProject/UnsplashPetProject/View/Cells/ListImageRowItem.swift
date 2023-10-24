//
//  ListImageRowItem.swift
//  UnsplashPetProject
//
//  Created by Sergey on 10.10.2023.
//

import SwiftUI
import Combine

struct ListImageRowItem: View {
  
  @Binding var item: ImageResponseDomain
  @Binding var isLoading: Bool
  
    var body: some View {
//      AsyncImage(url: URL(string: item.imageUrls.small))
//        .frame(width: 50, height: 50)
      
      Image(uiImage: item.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
      
      
      
      
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
