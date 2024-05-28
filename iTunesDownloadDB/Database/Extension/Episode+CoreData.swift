//
//  Episode+CoreData.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 28/05/24.
//

extension Episode: CoreDataPersistableType {
    
    var keyMap: [PartialKeyPath<Episode> : String] {
        [
             \.id: "id",
             \.podcastID: "podcastID",
             \.duration: "duration",
             \.title: "title",
             \.date: "date",
             \.url: "url"
        ]
    }
    
    typealias ManagedType = EpisodeEntity
}
