//
//  AuthorPhotoListView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 26.10.2023.
//

import SwiftUI

struct AuthorPhotoListView: View {
  
  @Environment(\.dismiss) var dismiss
  
  @ObservedObject var viewModel: AuthorPhotoListViewModel
  
  init(
    viewModel: AuthorPhotoListViewModel
  ) {
    self.viewModel = viewModel
    viewModel.requestInitialSetOfItems()
  }
  
  var body: some View {
    HStack {
      Button(action: {
        dismiss()
        
      }) {
        Image(systemName: "chevron.left")
          .resizable()
          .frame(width: 12, height: 18)
          .symbolRenderingMode(.multicolor)
          .foregroundColor(.black)
          
      }
      .frame(width: 12, height: 18, alignment: .leading)
      .padding(EdgeInsets(top: 12, leading: Constants.imageHorizontalPadding, bottom: 0, trailing: 0))
      Spacer()
    }
    
    ScrollView(.vertical, showsIndicators: false) {
      AsyncImage(url: URL(string: viewModel.imageInfo.user?.profileImage.large ?? "")) { image in
        image
          .resizable()
          .scaledToFill()
      } placeholder: {
        ProgressView()
      }
      .frame(width: 128, height: 128)
      .clipShape(Circle())
      
      Text(viewModel.imageInfo.user?.name ?? "")
        .font(.headline)
        .padding(EdgeInsets(top: 24, leading: 24, bottom: 0, trailing: 24))
      
      Text(viewModel.imageInfo.user?.instagramUsername ?? "")
        .font(.footnote)
        .foregroundStyle(.gray)
        .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
      
      HStack {
        VStack {
          var totalPhotos: String {
            guard let totalPhotos = viewModel.imageInfo.user?.totalPhotos else {
              return "0"
            }
            
            guard totalPhotos > 1000 else {
              return String(totalPhotos)
            }
            
            return "\(Int(totalPhotos / 1000)),\(Int(totalPhotos % 1000 / 100))k"
          }
          
          Text(totalPhotos)
            .font(.headline)
            .padding(EdgeInsets(top: 24, leading: 24, bottom: 0, trailing: 24))
          
          Text("Photos")
            .font(.footnote)
            .foregroundStyle(.gray)
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 24, trailing: 24))
        }
        
        VStack {
          var totalLikes: String {
            guard let totalLikes = viewModel.imageInfo.user?.totalLikes else {
              return "0"
            }
            
            guard totalLikes > 1000 else {
              return String(totalLikes)
            }
            
            return "\(Int(totalLikes / 1000)),\(Int(totalLikes % 1000 / 100))k"
          }
          
          Text(totalLikes)
            .font(.headline)
            .padding(EdgeInsets(top: 24, leading: 24, bottom: 0, trailing: 24))
          
          Text("Likes")
            .font(.footnote)
            .foregroundStyle(.gray)
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 24, trailing: 24))
        }
      }
      
      HStack(alignment: .top, spacing: Constants.imageSpacing) {
        ForEach(viewModel.columns) { column in
          LazyVStack(spacing: Constants.imageSpacing) {
            ForEach (column.gridItems) { gridItem in
              NavigationLink(destination: ImageDetailView(
                viewModel: ImageDetailViewModel(
                  networkService: viewModel.networkService, gridItem: gridItem, isAuthorsImageDetail: true
                )
              )) {
                let cellWidth = (UIScreen.main.bounds.width - Constants.imageSpacing * 3) / 2.0
                
                ImageCellView(viewModel: gridItem.imageCellViewModel)
                  .frame(width: cellWidth, height: cellWidth * gridItem.ratio, alignment: .center)
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
    .navigationBarHidden(true)
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
