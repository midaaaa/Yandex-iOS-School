//
//  NetworkClient.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case httpError(Int, Data?)
    case decodingError(Error)
    case encodingError(Error)
    case noData
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL."
        case .httpError(let code, _):
            return "Ошибка HTTP: код \(code)"
        case .decodingError(let error):
            return "Ошибка декодирования: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Ошибка кодирования: \(error.localizedDescription)"
        case .noData:
            return "Нет данных от сервера."
        case .unauthorized:
            return "Неавторизованный доступ."
        case .unknown(let error):
            return "Неизвестная ошибка: \(error.localizedDescription)"
        }
    }
}

final class NetworkClient {
    private let token: String? = "2c2Fz4zRwrHi64O0qGKXaq1c"

    private let baseURL = URL(string: "https://shmr-finance.ru/api/v1")!

    func request<Request: Encodable, Response: Decodable>(
        path: String,
        method: String = "GET",
        body: Request? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> Response {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else { throw NetworkError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw NetworkError.encodingError(error)
            }
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    throw NetworkError.unauthorized
                }
                throw NetworkError.httpError(httpResponse.statusCode, data)
            }
            if httpResponse.statusCode == 204 {
                return (EmptyResponse() as! Response)
            }
            guard !data.isEmpty else { throw NetworkError.noData }
            do {
                let decoded = try JSONDecoder().decode(Response.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
