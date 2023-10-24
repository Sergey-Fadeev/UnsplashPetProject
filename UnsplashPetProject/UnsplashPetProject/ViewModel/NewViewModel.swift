//
//  NewViewModel.swift
//  UnsplashPetProject
//
//  Created by Sergey on 24.10.2023.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = ImageLoaderViewModel()
    
    var body: some View {
        VStack {
            if viewModel.images.isEmpty {
                // Если массив картинок пуст, показываем индикатор загрузки
                ProgressView()
            } else {
                // Иначе отображаем каждую загруженную картинку
                ScrollView {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            // Запускаем загрузку картинок
            viewModel.loadImages()
        }
    }
}

class ImageLoaderViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    private var cancellables: Set<AnyCancellable> = []
    
    func loadImages() {
        let imageURLs: [URL] = [
            URL(string: "https://images.unsplash.com/photo-1682685797507-d44d838b0ac7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTM0MzF8MXwxfGFsbHwxfHx8fHx8Mnx8MTY5ODE1MDE0Nnw&ixlib=rb-4.0.3&q=80&w=1080")!,
            URL(string: "https://images.unsplash.com/photo-1697572801935-60d4a28a861b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTM0MzF8MHwxfGFsbHwyfHx8fHx8Mnx8MTY5ODE1MDE0Nnw&ixlib=rb-4.0.3&q=80&w=1080")!,
            URL(string: "https://images.unsplash.com/photo-1697723678949-5184d37f11ff?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTM0MzF8MHwxfGFsbHwzfHx8fHx8Mnx8MTY5ODE1MDE0Nnw&ixlib=rb-4.0.3&q=80&w=1080")!,
            URL(string: "https://images.unsplash.com/photo-1697644371824-41d4d0a8a12f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTM0MzF8MHwxfGFsbHw0fHx8fHx8Mnx8MTY5ODE1MDE0Nnw&ixlib=rb-4.0.3&q=80&w=1080")!,
            URL(string: "https://images.unsplash.com/photo-1697723831958-63bbdbe09962?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTM0MzF8MHwxfGFsbHw1fHx8fHx8Mnx8MTY5ODE1MDE0Nnw&ixlib=rb-4.0.3&q=80&w=1080")!,
            URL(string: "https://images.unsplash.com/photo-1682687981807-35e55307a7bb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTM0MzF8MXwxfGFsbHw2fHx8fHx8Mnx8MTY5ODE1MDE0Nnw&ixlib=rb-4.0.3&q=80&w=1080")!,
            URL(string: "https://images.unsplash.com/photo-1697519754376-5652952107b8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTM0MzF8MHwxfGFsbHw3fHx8fHx8Mnx8MTY5ODE1MDE0Nnw&ixlib=rb-4.0.3&q=80&w=1080")!,
            URL(string: "https://images.unsplash.com/photo-1697506788707-53f5b1a1f1f3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTM0MzF8MHwxfGFsbHw4fHx8fHx8Mnx8MTY5ODE1MDE0Nnw&ixlib=rb-4.0.3&q=80&w=1080")!
        ]
        
        // Создаем массив из сетевых запросов
        let imageLoaders = imageURLs.map { url -> AnyPublisher<UIImage?, Never> in
            URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ -> UIImage? in UIImage(data: data) }
                .catch { _ in Just(nil) }
                .eraseToAnyPublisher()
        }
        
        // Комбинируем все сетевые запросы в один массив картинок
        Publishers.Sequence(sequence: imageLoaders)
            .flatMap { $0 }
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] images in
                self?.images = images
            }
            .store(in: &cancellables)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
