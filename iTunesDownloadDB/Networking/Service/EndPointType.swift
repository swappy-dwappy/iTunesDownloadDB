//
//  EndPointType.swift
//  Acharya Prashant
//
//  Created by Sonkar, Swapnil on 12/05/24.
//

import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var token: String? { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
    var uploadFile: URL? { get }
    var uploadData: Data? { get }
}

extension EndPointType {
    var token: String? {
        return nil
    }
    
    var uploadFile: URL? {
        return nil
    }
    
    var uploadData: Data? {
        return nil
    }
}
