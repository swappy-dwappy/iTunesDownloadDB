//
//  ContentView.swift
//  iTunes
//
//  Created by Sonkar, Swapnil on 15/05/24.
//

import CoreData
import SwiftUI

struct ContentView: View {
    
//    @Environment(\.managedObjectContext) private var moc
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                HeaderView(podcast: viewModel.podcast)
                
                if let podcast = viewModel.podcast {
                    ForEach(podcast.episodes) { episode in
                        EpisodeRow(episode: episode) {
                            toggleDownload(for: episode)
                        }
                    }
                    .onDelete(perform: viewModel.deleteEpisode)
                } else {
                    ForEach(0..<5) { _ in
                        EpisodeRow(episode: nil, onButtonPressed: {})
                    }
                }
            }
            .navigationTitle("Podcast")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.gray, for: .navigationBar)
            .alert("Error", isPresented: $viewModel.showPodcastAPIError, actions: {}) {
                Text(viewModel.podcastAPIError?.localizedDescription ?? "Podcast API error!")
            }
            .listStyle(.plain)
            .toolbar {
                Button("", systemImage: "trash") {
                    do {
//                        // 1
//                        Task {
//                            await PCShared.deleteAllEntities()
//                            viewModel.refreshDBFetch()
//                            await viewModel.fetchPodcast()
//                        }
                        
//                        // 2
//                        let isDeleted = try PCShared.deleteEntity(entity: PodcastEntity.self)
//                        if isDeleted {
//                            Task {
//                                await viewModel.fetchPodcast()
//                            }
//                        }
                        
                        //3
                        let isDeleted = try PCShared.deleteEntityInBackground(entity: PodcastEntity.self)
                        if isDeleted {
                            Task {
                                await viewModel.fetchPodcast()
                            }
                        }
                        
//                        //4
//                        Task {
//                            let isDeleted = try await PCShared.deleteEntityInBackgroundAlternative(entity: PodcastEntity.self)
//                            if isDeleted {
//                                await viewModel.fetchPodcast()
//                            }
//                        }
                    } catch {
                        fatalError("Core Data Crash")
                    }
                }
            }
            .task {
                await viewModel.fetchPodcast()
            }
        }
    }
}

private extension ContentView {
    func toggleDownload(for episode: Episode) {
        if episode.isDownloading {
            viewModel.pauseDownload(for: episode)
        } else {
            if episode.progress > 0 {
                viewModel.resumeDownload(for: episode)
            } else {
                Task {
                    await viewModel.download(episode: episode)
                }
            }
        }
    }
}

struct HeaderView: View {
    let podcast: Podcast?
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: podcast?.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(16.0)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 140, height: 140)

            Text(podcast?.title ?? "Podcast Title")
                .font(.largeTitle.bold())
            
            Text(podcast?.artist ?? "Podcast Artist")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom)
        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
        .redacted(reason: podcast == nil ? .placeholder : [])
    }
}

#Preview {
    ContentView()
}
