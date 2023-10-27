//
//  AuthorPhotoListView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 26.10.2023.
//

import SwiftUI

struct AuthorPhotoListView: View {
  
  @ObservedObject var viewModel: AuthorPhotoListViewModel
  
  init(
    viewModel: AuthorPhotoListViewModel
  ) {
    self.viewModel = viewModel
    viewModel.requestInitialSetOfItems()
  }
  
  var body: some View {
    ScrollView {
      HStack(alignment: .top, spacing: Constants.imageSpacing) {
        ForEach(viewModel.columns) { column in
          LazyVStack(spacing: Constants.imageSpacing) {
            ForEach (column.gridItems) { gridItem in
              NavigationLink(destination: ImageDetailView(viewModel: ImageDetailViewModel(networkService: viewModel.networkService, gridItem: gridItem))) {
                Image(uiImage: gridItem.uiImage)
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .cornerRadius(12)
              }
            }
            
            GeometryReader { geometry in
              Color.clear.preference(key: ViewOffsetKey.self, value: geometry.frame(in: .named("scrollView")).minY)
            }
            .frame(height: 0)
          }
        }
      }
      .padding(.horizontal, Constants.imageHorizontalPadding)
    }
    .overlay {
      if viewModel.dataIsLoading {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.white)
          .frame(width: 75, height: 75)
          .opacity(0.8)
        
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
          .scaleEffect(1.5, anchor: .center)
      }
    }
    .coordinateSpace(name: "scrollView")
    .onPreferenceChange(ViewOffsetKey.self) { minY in
      if minY > -150 {
        viewModel.requestMoreItemsIfNeeded()
      }
    }
  }
}
//
//#Preview {
//  AuthorPhotoListView()
//}
