//
//  PodcastService.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 16/06/24.
//

import Foundation

class PodcastService: PodcastServiceType {
    
    @MainActor
    func getPodcast() async -> Result<Podcast, Error> {
        
//        let episode = \(PodcastEntity.episodes!.allObjects.first as! Episode).title
//        let path = episode.title
//        let sortDes = SortDescriptor(episode, order: .reverse)
        if let podcast = PCShared.getSafeObject(entity: PodcastEntity.self).first {
            return .success(podcast)
        } else {
            let result = await NetworkManager().getPodcast(id: 1386867488, media: "podcast", entity: "podcastEpisode", limit: 10)
            switch result {
            case let .success(podcast):
                let _ = PodcastEntity.create(safe: podcast)
                try? PCShared.save()
                return .success(podcast)
                
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
}
