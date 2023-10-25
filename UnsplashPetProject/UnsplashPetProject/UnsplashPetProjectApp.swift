//
//  UnsplashPetProjectApp.swift
//  UnsplashPetProject
//
//  Created by Sergey on 09.10.2023.
//

import SwiftUI

@main
struct UnsplashPetProjectApp: App {
    var body: some Scene {
      WindowGroup {
        InfiniteListView(viewModel: ImageLoaderViewModel(networkService: NetworkService.shared))
      }
    }
}
