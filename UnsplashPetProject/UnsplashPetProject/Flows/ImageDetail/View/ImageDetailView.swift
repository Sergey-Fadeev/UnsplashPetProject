//
//  ImageDetailView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 26.10.2023.
//

import SwiftUI

struct ImageDetailView: View {
  
  @ObservedObject var viewModel: ImageDetailViewModel
  
  init(viewModel: ImageDetailViewModel) {
    self.viewModel = viewModel
    viewModel.bind()
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
    
    return ScrollView {
      VStack {
        Image(uiImage: UIImage(data: viewModel.imageData) ?? UIImage(named: "launchScreen")!)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .cornerRadius(12)
          .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
        
        if let altDescription = viewModel.gridItem.imageInfo.altDescription {
          Text(altDescription)
            .font(.headline)
            .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        if let description = viewModel.gridItem.imageInfo.description {
          Text(description)
            .font(.subheadline)
            .padding(EdgeInsets(top: 24, leading: 12, bottom: 0, trailing: 12))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        Text(createdDate)
          .font(.footnote)
          .padding(EdgeInsets(top: 6, leading: 12, bottom: 0, trailing: 12))
          .frame(maxWidth: .infinity, alignment: .trailing)
        
        HStack {
          Text("Автор: \(viewModel.gridItem.imageInfo.user?.name ?? "")")
          Spacer()
          NavigationLink(
            destination: AuthorPhotoListView(),
            label: {
              Text("Перейти к фотографиям автора")
                .font(.caption)
                .foregroundColor(.blue)
            })
        }
        .padding()
      }
      .navigationBarTitleDisplayMode(.inline)
      
      Spacer()
    }
  }
  
}

//#Preview {
//  ImageDetailView()
//}
