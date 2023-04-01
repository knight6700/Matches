
import Foundation

public struct API {
    var baseURL: String {
        // TODO: - Add More Base URL For Deferent Target Environment
         #if DEBUG
         return "api.football-data.org/v2/"
         #elseif RELEASE
         return "api.football-data.org/v2/"
         #else
         return "api.football-data.org/v2/"
         #endif
    }
    
    
    var schema: String {
        // TODO: - Add More Schema For Deferent Target Environment
        "https"
    }
    
    let endpoint: String
    var body: Encodable?
    var method: API.Method
    var headers: [String: String?] {
        [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "X-Auth-Token": AppEnvironment.apiKey
        ]
    }
    
    let decoder = JSONDecoder()
    let urlSession = URLSession.shared
    private var queryItems: [URLQueryItem]? {
        guard let body = body?.asDictionary,
              method == .get
        else {
            return nil
        }
        return body.map {URLQueryItem(name: $0.key, value: "\($0.value)")}
    }
    
    public init(endpoint: String,
                body: Encodable? = nil,
                method: API.Method
    ) {
        self.endpoint = endpoint
        self.body = body
        self.method = method
    }
    
    func buildRequest() -> URLRequest? {
        var urlRequest = generateQueryURLRequest()
        headers.forEach {
            urlRequest?.addValue($0.value ?? "", forHTTPHeaderField: $0.key)
        }
        urlRequest?.httpMethod = method.rawValue
        guard method != .get else {
            return urlRequest
        }
        urlRequest?.httpBody = encode
        
        return urlRequest
    }
    
    func generateQueryURLRequest() -> URLRequest? {
        var components = URLComponents()
        components.scheme = schema
        components.path = "\(baseURL)\(endpoint)"
        components.queryItems = queryItems
        guard let url = components.url else {
            return nil
        }
        return .init(url: url)
    }
    
    var  encode: Data? {
        get {
            let encoder = JSONEncoder()
            guard let body = body else {
                return nil
            }
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(body)
        }
    }
}


public extension API {
    enum Method: String {
        case post = "POST"
        case get = "GET"
        case delete = "DELETE"
        case put = "PUT"
        case patch = "PATCH"
    }
}
