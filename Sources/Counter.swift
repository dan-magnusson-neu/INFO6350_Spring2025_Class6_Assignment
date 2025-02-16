protocol Counter: Codable {
    var currentValue: Int? { get set }
}
struct CounterRequest: Counter {
    var currentValue: Int?
    
    private enum CodingKeys: String, CodingKey {
        case currentValue = "current_value"
    }
}
struct CounterResponse: Counter, CustomStringConvertible {
    var currentValue: Int?
    var namespace: String?
    var key: String?
    var exists: Bool? = nil
    var description: String {
        "\(namespace?.description ?? "nil")/\(key?.description ?? "nil"): \(currentValue?.description ?? "nil")"
    }
    private enum CodingKeys: String, CodingKey {
        case currentValue = "current_value"
        case namespace, key, exists
    }
}
