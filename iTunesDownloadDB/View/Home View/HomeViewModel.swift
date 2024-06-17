//
//  HomeViewModel.swift
//  iTunes
//
//  Created by Sonkar, Swapnil on 18/05/24.
//

import Combine
import Foundation

class HomeViewModel: NSObject, ObservableObject {
    
    @Published var showPodcastAPIError: Bool = false
    var podcastAPIError: Error?
    @Published var podcast: Podcast?
    private var downloads: [URL: Download] = [:]
    var cancellables = Set<AnyCancellable>()
    let podcastService: PodcastServiceType
    
    private lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
    }()
    
    init(podcastType: PodcastServiceType = PodcastService()) {
        self.podcastService = podcastType
    }
}

extension HomeViewModel {
    
    func refreshDBFetch() {
        let podcast = PCShared.getSafeObject(entity: PodcastEntity.self).first
        Task {@MainActor in
            self.podcast = podcast
        }
    }
    
    func deleteEpisode(at offset: IndexSet) {
        if let index = offset.first, let episode = podcast?.episodes[index], let id = episode.id {
            let predicate = NSPredicate(format: "id == \"\(id)\"")
            let isDeleted = (try? PCShared.deleteEntity(entity: EpisodeEntity.self, predicates: [predicate])) ?? false
            if isDeleted {
                refreshDBFetch()
            } else {
                fatalError("Core Data Crash Swapnil")
            }
        }
    }
}

// API
extension HomeViewModel {
   
    @MainActor
    func fetchPodcast() async {
        switch await podcastService.getPodcast() {
        case .success(let podcast):
            self.podcast = podcast
            
        case .failure(let error):
            podcastAPIError = error
            showPodcastAPIError = true
            print(error)
        }
    }
    
    @MainActor
    func download(episode: Episode) async {
        guard downloads[episode.url] == nil  else { return }
        
        let download = Download(url: episode.url, downloadSession: downloadSession)
        download.startDownload()
        download.handleCompletedFile = { [weak self] event in
            self?.process(event, for: episode)
        }
        downloads[episode.url] = download
        podcast?[episode.id]?.isDownloading = true
    }
    
    func pauseDownload(for episode: Episode) {
        downloads[episode.url]?.pause()
        podcast?[episode.id]?.isDownloading = false
    }
    
    func resumeDownload(for episode: Episode) {
        downloads[episode.url]?.resume()
        podcast?[episode.id]?.isDownloading = true
    }
}

private extension HomeViewModel {
    func process(_ event: Download.Event, for episode: Episode) {
        switch event {
        case let .progress(currentBytes, totalBytes):
            podcast?[episode.id]?.update(currentBytes: currentBytes, totalBytes: totalBytes)
        case let .success(url):
            saveFile(for: episode, at: url)
            downloads[episode.url] = nil
        case .failed(_):
            podcast?[episode.id]?.isDownloading = false
        }
    }

    func saveFile(for episode: Episode, at url: URL) {
        guard let directoryURL = podcast?.directoryURL else { return }
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryURL.path()) {
            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        print("Url: \(url)")
        print("Episode: \(episode.fileURL)")
        do {
            try fileManager.moveItem(at: url, to: episode.fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}
