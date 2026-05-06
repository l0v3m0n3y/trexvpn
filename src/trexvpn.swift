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

public class Trexvpn{
    private let api = "https://t-rex.top/api"
    private var headers: [String: String]
    
    public init() {
        self.headers = [
        "x-client-platform":"android",
        "Connection":"keep-alive",
        "Accept-Encoding":"deflate, zstd",
        "Accept-Language":"en-US,en;q=0.9",
        "User-Agent":"T-REX VPN Client/android/1.0.34"
        ]

    }
   

    public func register(email: String, password: String) async throws -> Any {
        let urlString = "\(api)/register"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["email": email,"password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        let (responseData, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: responseData)
        if let dict = json as? [String: Any],
           let token = dict["token"] as? String {
            headers["authorization"] = "Bearer \(token)"
        }
        return json
    }

    public func get_servers() async throws -> Any {
        guard let url = URL(string: "\(api)/vpn/untrusted-proxies") else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let (data, _) = try await URLSession.shared.data(for: request)
        return  try JSONSerialization.jsonObject(with: data)
    }

    public func login(email: String, password: String) async throws -> Any {
        let urlString = "\(api)/auth/login"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["email": email,"password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: responseData)
        if let dict = json as? [String: Any],
           let token = dict["token"] as? String {
            headers["authorization"] = "Bearer \(token)"
        }
        return json
    }

    public func forgot_password(email: String) async throws -> Any {
        let urlString = "\(api)/auth/forgot-password"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["email": email]
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (responseData, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: responseData)
        return json
    }
}
