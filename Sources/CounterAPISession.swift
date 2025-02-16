import Foundation

class CounterAPISession {
    static let endpointBase: String = "https://letscountapi.com/"
    private let path: Path
    
    init(namespace: String, key: String) {
        self.path = Path(namespace: namespace, key: key)
    }
    
    func createCounter(startingWith count: Int?) async throws -> CounterResponse {
        var counter: Data?
        if let count = count {
            counter = try JSONEncoder().encode(CounterRequest(currentValue: count))
        } else {
            counter = try JSONEncoder().encode(CounterRequest(currentValue: 0))
        }
        return try await sendRequest(fromRoute: .base,
                                     inSession: path,
                                     usingMethod: .post,
                                     bodyData: counter)
    }
    
    func getCounterValue() async throws -> CounterResponse {
        return try await sendRequest(fromRoute: .base,
                                     inSession: path,
                                     usingMethod: .get)
    }
    
    func incrementCounter() async throws -> CounterResponse {
        return try await sendRequest(fromRoute: .increment,
                                     inSession: path,
                                     usingMethod: .post)
    }
    
    func decrementCounter() async throws -> CounterResponse {
        return try await sendRequest(fromRoute: .decrement,
                                     inSession: path,
                                     usingMethod: .post)
    }
    
    func updateCounter(to count: Int) async throws -> CounterResponse {
        let counter = try JSONEncoder().encode(CounterRequest(currentValue: count))
        return try await sendRequest(fromRoute: .update,
                                     inSession: path,
                                     usingMethod: .post,
                                     bodyData: counter)
    }
    
    private func sendRequest(fromRoute route: Route,
                             inSession session: Path,
                             usingMethod method: HTTPMethod = .get,
                             bodyData data: Data? = nil) async throws -> CounterResponse {
        let route = route == .base ? "" : "/\(route.rawValue)"
        guard let url = URL(string: "\(CounterAPISession.endpointBase)\(session.namespace)/\(session.key)\(route)") else {
            throw NetworkError.failedToCreateURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if method == .post {
            request.httpBody = data ?? "{ }".data(using: .utf8)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.responseNotValidHTTP
        }
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.networkError(code: httpResponse.statusCode)
        }
        return try JSONDecoder().decode(CounterResponse.self, from: data)
    }

    enum NetworkError: Error {
        case failedToCreateURL
        case responseNotValidHTTP
        case networkError(code: Int)
    }
    
    enum Route: String {
        case base
        case increment
        case decrement
        case update
    }
    
    enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
    }
    
    private struct Path {
        let namespace: String
        let key: String
    }
}

