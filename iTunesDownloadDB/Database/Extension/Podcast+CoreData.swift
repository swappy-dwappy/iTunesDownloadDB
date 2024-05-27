//
//  Podcast+CoreData.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 26/05/24.
//

extension Podcast: CoreDataPersistableType {
    
    var keyMap: [PartialKeyPath<Podcast>: String] {
        [
             \.id: "id",
             \.title: "title",
             \.artist: "artist",
             \.imageURL: "imageURL",
             \.episodes: "episodes"
        ]
    }
    
    typealias ManagedType = PodcastEntity
}
