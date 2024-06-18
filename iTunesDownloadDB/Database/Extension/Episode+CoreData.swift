//
//  Episode+CoreData.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 28/05/24.
//

import CoreData

extension EpisodeEntity: SafeObjectType {
    
    static func create(safe: Episode, with context: NSManagedObjectContext = mainContext) -> EpisodeEntity {
        let entity = EpisodeEntity(context: context)
        entity.id = Int64(safe.id ?? 0)
        entity.duration = Int64(safe.duration.components.seconds)
        entity.title = safe.title
        entity.date = safe.date
        entity.url = safe.url
        return entity
    }
    
    func toSafeObject() -> Episode {
        let episode = Episode(id: Int(id), podcastID: Int(podcastID), duration: .seconds(duration), title: title ?? "", date: date ?? .now, url: url!, currentBytes: 0, totalBytes: 0)
        return episode
    }
}
