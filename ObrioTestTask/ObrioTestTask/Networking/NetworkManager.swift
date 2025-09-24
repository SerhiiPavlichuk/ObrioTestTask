//
//  NetworkManager.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//


import Foundation

enum NetworkError: Error {
    case noData
    case invalidURL
    case network
    case decode(String)
    case bodyError
}

final class NetworkManager<T: Decodable, Provider: APIEndpoint> {
    
    func request(endpoint: Provider) async throws -> T {
        guard let url = buildURL(for: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let request = buildURLRequest(for: endpoint, with: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.network
        }
        
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    
    private func buildURL(for endpoint: Provider) -> URL? {
        var components = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
        if let urlParameters = endpoint.urlParameters {
            components?.queryItems = urlParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return components?.url
    }
    
    private func buildURLRequest(for endpoint: Provider, with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        if let headers = endpoint.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let bodyParameters = endpoint.bodyParameters, endpoint.method == .post {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                logPrint(NetworkError.bodyError, level: .error)
            }
        }
        return request
    }
}

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
            task.resume()
        }
    }
}
