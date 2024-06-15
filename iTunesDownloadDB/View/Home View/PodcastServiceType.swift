//
//  PodcastServiceType.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 16/06/24.
//

import Foundation

protocol PodcastServiceType {
    
    func getPodcast() async -> Result<Podcast, Error>
}
