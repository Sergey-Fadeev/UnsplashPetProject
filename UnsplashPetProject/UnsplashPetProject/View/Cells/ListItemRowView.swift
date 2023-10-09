//
//  ListItemRowView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 09.10.2023.
//

import SwiftUI

struct ListItemRowView: View {
  
  @Binding var item: APIUnsplashItem
  
    var body: some View {
      Text(item.label)
    }
  
}

//#Preview {
//    ListItemRowView()
//}
