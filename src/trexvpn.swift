import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.unknown))
                }
            }
            task.resume()
        }
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public class Trexvpn {
    private let api = "https://t-rex.top/api"
    private var headers: [String: String]
    
    public init() {
        self.headers = [
            "x-client-platform": "android",
            "Connection": "keep-alive",
            "Accept-Encoding": "deflate, zstd",
            "Accept-Language": "en-US,en;q=0.9",
            "User-Agent": "T-REX VPN Client/android/1.0.34"
        ]
    }
    
    private func fetchJSON(from urlString: String,method: HTTPMethod = .get,body: Data? = nil,queryParameters: [String: String]? = nil) async throws -> Any {
        var urlComponents = URLComponents(string: urlString)
        if let queryParameters = queryParameters {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = urlComponents?.url else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: data)
    }

    
    public func register(email: String, password: String) async throws -> Any {
        let body: [String: Any] = ["email": email, "password": password]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let response = try await fetchJSON(
            from: "\(api)/register",
            method: .post,
            body: bodyData
        )
        
        if let dict = response as? [String: Any],
           let token = dict["token"] as? String {
            headers["authorization"] = "Bearer \(token)"
        }
        
        return response
    }
    
    public func login(email: String, password: String) async throws -> Any {
        let body: [String: Any] = ["email": email, "password": password]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let response = try await fetchJSON(
            from: "\(api)/auth/login",
            method: .post,
            body: bodyData
        )
        
        if let dict = response as? [String: Any],
           let token = dict["token"] as? String {
            headers["authorization"] = "Bearer \(token)"
        }
        
        return response
    }
    
    public func forgotPassword(email: String) async throws -> Any {
        let body: [String: Any] = ["email": email]
        let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        return try await fetchJSON(
            from: "\(api)/auth/forgot-password",
            method: .post,
            body: bodyData
        )
    }
    
    public func get_servers() async throws -> Any {
        return try await fetchJSON(from: "\(api)/vpn/untrusted-proxies")
    }
}
