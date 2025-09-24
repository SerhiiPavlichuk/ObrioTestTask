//
//  HTTPMethod.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//


import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var bodyParameters: [String: Any]? { get }
    var urlParameters: [String: String]? { get }
}
