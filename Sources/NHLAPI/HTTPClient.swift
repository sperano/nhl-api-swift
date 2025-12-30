import Foundation

// MARK: - HTTP Data Provider Protocol

/// Protocol for providing HTTP data, enabling dependency injection for testing
public protocol HTTPDataProvider: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Default implementation using URLSession
extension URLSession: HTTPDataProvider {}

/// API endpoints for the NHL API
enum Endpoint {
    case apiWebV1
    case apiCore
    case apiStats
    case searchV1

    var baseURL: URL {
        switch self {
        case .apiWebV1: URL(string: "https://api-web.nhle.com/v1/")!
        case .apiCore: URL(string: "https://api.nhle.com/")!
        case .apiStats: URL(string: "https://api.nhle.com/stats/rest/")!
        case .searchV1: URL(string: "https://search.d3.nhle.com/api/v1/")!
        }
    }
}

/// HTTP client for making API requests
public actor HTTPClient {
    private let dataProvider: HTTPDataProvider
    private let decoder: JSONDecoder

    /// Creates an HTTPClient with a custom data provider (useful for testing)
    public init(dataProvider: HTTPDataProvider) {
        self.dataProvider = dataProvider
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    /// Creates an HTTPClient with default URLSession configuration
    public init(config: ClientConfig = .default) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = config.timeout
        configuration.timeoutIntervalForResource = config.timeout * 2
        self.dataProvider = URLSession(configuration: configuration)
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func getJSON<T: Decodable>(
        endpoint: Endpoint,
        resource: String,
        queryParams: [String: String]? = nil
    ) async throws -> T {
        let url = try buildURL(base: endpoint.baseURL, resource: resource, queryParams: queryParams)
        let request = URLRequest(url: url)

        let (data, response) = try await performRequest(request)
        try validateResponse(response, for: resource)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NHLAPIError.jsonError(underlying: error)
        }
    }

    // MARK: - Private Helpers

    private func buildURL(base: URL, resource: String, queryParams: [String: String]?) throws -> URL {
        var url = base.appending(path: resource)

        if let params = queryParams, !params.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
            guard let finalURL = components?.url else {
                throw NHLAPIError.other(message: "Could not construct URL with query parameters")
            }
            url = finalURL
        }

        return url
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await dataProvider.data(for: request)
        } catch {
            throw NHLAPIError.requestError(underlying: error)
        }
    }

    private func validateResponse(_ response: URLResponse, for resource: String) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NHLAPIError.other(message: "Invalid response type")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw mapError(statusCode: httpResponse.statusCode, resource: resource)
        }
    }

    private func mapError(statusCode: Int, resource: String) -> NHLAPIError {
        let message = "Request to \(resource) failed"

        switch statusCode {
        case 400: return .badRequest(message: message)
        case 401, 403: return .unauthorized(message: message)
        case 404: return .resourceNotFound(message: message)
        case 429: return .rateLimitExceeded
        case 500...599: return .serverError(statusCode: statusCode, message: message)
        default: return .apiError(statusCode: statusCode, message: "Unexpected error: \(message)")
        }
    }
}
