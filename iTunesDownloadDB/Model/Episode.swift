//
//  Episode.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 27/05/24.
//

import Foundation

struct Episode: Identifiable, Codable {
    var id: Int?
    let podcastID: Int
    let duration: Duration
    let title: String
    let date: Date
    let url: URL
    var isDownloading = false
    private(set) var currentBytes: Int64 = 0
    private(set) var totalBytes: Int64 = 0
    
    var progress: Double {
        guard totalBytes > 0 else { return 0.0 }
        return Double(currentBytes) / Double(totalBytes)
    }
    
    mutating func update(currentBytes: Int64, totalBytes: Int64) {
            self.currentBytes = currentBytes
            self.totalBytes = totalBytes
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case podcastID = "collectionId"
        case duration = "trackTimeMillis"
        case title = "trackName"
        case date = "releaseDate"
        case url = "episodeUrl"
    }
    
    init(id: Int? = nil, podcastID: Int, duration: Duration, title: String, date: Date, url: URL, isDownloading: Bool = false, currentBytes: Int64, totalBytes: Int64) {
        self.id = id
        self.podcastID = podcastID
        self.duration = duration
        self.title = title
        self.date = date
        self.url = url
        self.isDownloading = isDownloading
        self.currentBytes = currentBytes
        self.totalBytes = totalBytes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.podcastID = try container.decode(Int.self, forKey: .podcastID)
        let duration = try container.decode(Int.self, forKey: .duration)
        self.duration = .milliseconds(duration)
        self.title = try container.decode(String.self, forKey: .title)
        self.date = try container.decode(Date.self, forKey: .date)
        self.url = try container.decode(URL.self, forKey: .url)
    }
    
    var fileURL: URL {
        URL.documentsDirectory
            .appending(path: "\(podcastID)")
            .appending(path: "\(String(describing: id))")
            .appendingPathExtension("mp3")
    }
}
