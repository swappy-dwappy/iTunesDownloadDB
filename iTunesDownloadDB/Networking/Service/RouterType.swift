//
//  RouterType.swift
//  Acharya Prashant
//
//  Created by Sonkar, Swapnil on 12/05/24.
//

import Foundation

protocol RouterType: AnyObject {
    
    var urlSession: URLSession { get set }
    func request(route: EndPointType) async throws -> (Data, URLResponse)
    func download(route: EndPointType) async throws -> (URL, URLResponse)
    func uploadFromFile(route: EndPointType) async throws -> (Data, URLResponse)
    func uploadFromData(route: EndPointType) async throws -> (Data, URLResponse)
}
