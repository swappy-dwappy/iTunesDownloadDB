//
//  NetworkManager.swift
//  Acharya Prashant
//
//  Created by Sonkar, Swapnil on 12/05/24.
//

import Foundation
import UIKit

enum NetworkResponse: LocalizedError {
    case success 
    case authenticationError
    case badRequest
    case outdated
    case failed
    case noData
    case unableToDecode
    case custom(errorDescription: String)
    
    var errorDescription: String? {
        switch self {
        case .success:
            return "Success"
        case .authenticationError:
            return "You need to be authenticated first."
        case .badRequest:
            return "Bad request"
        case .outdated:
            return "The url you requested is outdated."
        case .failed:
            return "Network request failed."
        case .noData:
            return "Response returned with no data to decode."
        case .unableToDecode:
            return "We could not decode the response."
        case .custom(let errorDescription):
            return errorDescription
        }
    }
}

enum NetworkEnvironment {
    case qa
    case production
    case staging
}

struct NetworkManager {

    static let environment: NetworkEnvironment = .production
    
    private let cache = NSCache<NSString, UIImage>()
    
    /// Sample func to download and cache image
    func getThumbnail(domain: String, basePath: String, key: String) async -> Result<UIImage, Error> {
        
        let cacheKey = basePath + key
        if let image = cache.object(forKey: cacheKey as NSString) {
            return .success(image)
        } else {
            do {
                let (url, response) = try await Router().download(route: ThumbnailApi.thumbnail(domain: domain, basePath: basePath, key: key))
                try handleNetworkResponseCode(response)
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    cache.setObject(image, forKey: cacheKey as NSString)
                    return .success(image)
                }
            } catch {
                return .failure(error)
            }
            
            return .failure(NetworkResponse.noData)
        }
    }
    
    func getPodcast(id: Int, media: String, entity: String, limit: Int) async -> Result<Podcast, Error> {
        do {
            let (data, response) = try await Router().request(route: PodcastApi.searchEpisode(id: id, media: media, entity: entity, limit: limit))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return getModelFromResponse(data: data, decoder: decoder, response: response)
        } catch {
            return .failure(error)
        }        
    }
}

extension NetworkManager {
    fileprivate func handleNetworkResponseCode(_ response: URLResponse) throws {
        
        guard let httpUrlResponse = response as? HTTPURLResponse else { throw (NetworkResponse.custom(errorDescription: "Invalid HTTP response")) }
        
        switch httpUrlResponse.statusCode {
        case 200...299: break
        case 401...500: throw NetworkResponse.authenticationError
        case 501...599: throw NetworkResponse.badRequest
        case 600: throw NetworkResponse.outdated
        default: throw NetworkResponse.failed
        }
    }
    
    fileprivate func getModelFromResponse<T: Decodable>(data: Data, decoder: JSONDecoder = JSONDecoder(), response: URLResponse) -> Result<T, Error> {
        do {
            try handleNetworkResponseCode(response)
            let model = try decoder.decode(T.self, from: data)
            return .success(model)
        } catch {
            return .failure(error)
        }
    }
}
