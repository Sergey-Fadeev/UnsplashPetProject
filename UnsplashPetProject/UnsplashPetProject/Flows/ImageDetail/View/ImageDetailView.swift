//
//  ImageDetailView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 26.10.2023.
//

import SwiftUI

struct ImageDetailView: View {
  
  @Environment(\.dismiss) var dismiss
  @ObservedObject var viewModel: ImageDetailViewModel
  
  init(viewModel: ImageDetailViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    var createdDate: String {
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      
      guard let date = dateFormatter.date(from: viewModel.gridItem.imageInfo.createdAt) else {
        return ""
      }
      
      dateFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
      let dateString = dateFormatter.string(from: date)
      
      return dateString
    }
    
    HStack {
      Button(action: {
        dismiss()
        
      }) {
        Image(systemName: "chevron.left")
          .resizable()
          .frame(width: 12, height: 16)
          .symbolRenderingMode(.multicolor)
          .foregroundColor(.black)
          
      }
      .frame(width: 12, height: 16, alignment: .leading)
      .padding(EdgeInsets(top: 12, leading: Constants.imageHorizontalPadding, bottom: 0, trailing: 0))
      Spacer()
    }
    
    ScrollView(.vertical, showsIndicators: false) {
      VStack {
        AsyncImage(url: URL(string: viewModel.gridItem.imageInfo.imageUrls.regular)) { image in
          image
            .resizable()
            .scaledToFill()
            .cornerRadius(12)
        } placeholder: {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.clear)
            .frame(width: 200, height: 200)
            .overlay {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                .scaleEffect(1.5, anchor: .center)
            }
        }
        
        if let altDescription = viewModel.gridItem.imageInfo.altDescription {
          Text(altDescription)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        if let description = viewModel.gridItem.imageInfo.description {
          Text(description)
            .font(.subheadline)
            .padding(.top, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        Text(createdDate)
          .font(.footnote)
          .padding(.top, 6)
          .frame(maxWidth: .infinity, alignment: .trailing)
        
        HStack {
          Text("Автор: \(viewModel.gridItem.imageInfo.user?.name ?? "")")
          Spacer()
          
          if !viewModel.isAuthorsImageDetail {
            NavigationLink(
              destination: AuthorPhotoListView(
                viewModel: AuthorPhotoListViewModel(
                  networkService: viewModel.networkService,
                  imageInfo: viewModel.gridItem.imageInfo
                )
              ),
              label: {
                Text("Перейти к фотографиям автора")
                  .font(.caption)
                  .foregroundColor(.blue)
              })
          }
        }
        .padding()
      }
      .navigationBarHidden(true)
      
      Spacer()
    }
    .padding(EdgeInsets(top: 16, leading: Constants.imageHorizontalPadding, bottom: 0, trailing: Constants.imageHorizontalPadding))
  }
  
}
