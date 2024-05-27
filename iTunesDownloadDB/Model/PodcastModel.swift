//
//  PodcastModel.swift
//  iTunes
//
//  Created by Sonkar, Swapnil on 14/05/24.
//

import Foundation

/*
 {
     "resultCount":6,
     "results":[
         {
             "collectionId":1386867488,
             "artistName":"Jonathan Pageau",
             "collectionName":"The Symbolic World",
             "artworkUrl600":"https://is5-ssl.mzstatic.com/image/thumb/Podcasts125/v4/1a/b1/d4/1ab1d4b8-ae33-da25-d3c1-b919bbf6b9e0/mza_4176360441897917495.jpg/600x600bb.jpg"
         },
         {
             "trackTimeMillis":3017000,
             "collectionId":1386867488,
             "trackId":1000600017070,
             "trackName":"275 - Michael Legaspi - Subjectivity and the Psalms",
             "releaseDate":"2023-02-16T16:00:17Z",
             "episodeUrl":"https://feeds.soundcloud.com/stream/1447464973-jonathan-pageau-307491252-275-michael-legaspi.mp3"
         }
 }
 */


struct Podcast: Codable {
    var id: Int?
    let title: String
    let artist: String
    let imageURL: URL
    var episodes: [Episode]
    
    subscript (episodeID: Episode.ID) -> Episode? {
        get {
            return episodes.first { $0.id == episodeID }
        }
        set {
            guard let newValue,
                  let index = episodes.firstIndex(where: { $0.id == episodeID })
            else { return }
            episodes[index] = newValue
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "collectionId"
        case title = "collectionName"
        case artist = "artistName"
        case imageURL = "artworkUrl600"
    }
    
    enum LookupCodingKeys: CodingKey {
        case results
    }
    
    init(from decoder: Decoder) throws {
        let lookupContainer = try decoder.container(keyedBy: LookupCodingKeys.self)
        var resultsContainer = try lookupContainer.nestedUnkeyedContainer(forKey: .results)
        let podcastContainer = try resultsContainer.nestedContainer(keyedBy: CodingKeys.self)
        self.id = try podcastContainer.decode(Int.self, forKey: .id)
        self.title = try podcastContainer.decode(String.self, forKey: .title)
        self.artist = try podcastContainer.decode(String.self, forKey: .artist)
        self.imageURL = try podcastContainer.decode(URL.self, forKey: .imageURL)
        var episodes = [Episode]()
        while !resultsContainer.isAtEnd {
            let episode = try resultsContainer.decode(Episode.self)
            episodes.append(episode)
        }
        self.episodes = episodes
    }
    
    var directoryURL: URL {
        URL.documentsDirectory
            .appending(path: "\(id)", directoryHint: .isDirectory)
    }
}

