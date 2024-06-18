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
        
        if var podcast = PCShared.getSafeObject(entity: PodcastEntity.self).first {
            podcast.episodes.sort()
            return .success(podcast)
        } else {
            let result = await NetworkManager().getPodcast(id: 1386867488, media: "podcast", entity: "podcastEpisode", limit: 5)
            switch result {
            case var .success(podcast):
                let _ = PodcastEntity.create(safe: podcast)
                try? PCShared.save()
                podcast.episodes.sort()
                return .success(podcast)
                
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
}
