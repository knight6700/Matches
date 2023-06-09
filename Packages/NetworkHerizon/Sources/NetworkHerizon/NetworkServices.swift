import Foundation

// Custom Network error
public enum NetworkError: Error, Equatable {
    case requestFailed(description: String)
    case jsonConversionFailure(description: String)
    case invalidData
    case responseUnsuccessful(description: String)
    case jsonParsingFailure
    case noInternet
    case failedSerialization
    case badRequest
    
    public var customDescription: String {
        switch self {
        case let .requestFailed(description): return "Request Failed error -> \(description)"
        case .invalidData: return "Invalid Data error)"
        case let .responseUnsuccessful(description): return "Response Unsuccessful error -> \(description)"
        case .jsonParsingFailure: return "JSON Parsing Failure error)"
        case let .jsonConversionFailure(description): return "JSON Conversion Failure -> \(description)"
        case .noInternet: return "No internet connection"
        case .failedSerialization: return "serialisation print for debug failed."
        case .badRequest: return " Invalid URL"
        }
    }
}
public struct NetworkService {
    
    public init(urlSession: URLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.decoder = decoder
    }
    
    var urlSession = URLSession.shared
    var decoder = JSONDecoder()
    
    public func fetch<T: Decodable>(
        type: T.Type,
        with api: API,
        body: Encodable?) async throws -> T { // 1
            guard let urlRequest = api.buildRequest()
            else {
                throw NetworkError.badRequest
            }
            // intialise url session
            let (data, response) = try await urlSession.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.requestFailed(description: "unvalid response")
            }
            guard httpResponse.statusCode == 200 else {
                throw NetworkError.responseUnsuccessful(description: "status code \(httpResponse.statusCode)")
            }
            do {
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                // 3 try to decoding
                return try decoder.decode(type, from: data)
            } catch {
                // catch error
                throw NetworkError.jsonConversionFailure(description: error.localizedDescription)
            }
    }
}
