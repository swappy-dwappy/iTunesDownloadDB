//
//  Podcast+CoreData.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 26/05/24.
//

import Foundation

extension PodcastEntity: SafeObjectType {
    
    static func create(safe: Podcast) -> PodcastEntity {
        let enitity = PodcastEntity(context: mainContext)
        enitity.id = Int64(safe.id ?? 0)
        enitity.title = safe.title
        enitity.artist = safe.artist
        enitity.imageURL = safe.imageURL
        for episode in safe.episodes {
            enitity.addToEpisodes(EpisodeEntity.create(safe: episode))
        }
        
        return enitity
    }
    
    func toSafeObject() -> Podcast {
        var podcast = Podcast(id: Int(id), title: title ?? "", artist: artist ?? "", imageURL: imageURL!, episodes: [])
        if let episodes = episodes?.allObjects as? [EpisodeEntity] {
            podcast.episodes = episodes.map { $0.toSafeObject() }
        }

        return podcast
    }
}
