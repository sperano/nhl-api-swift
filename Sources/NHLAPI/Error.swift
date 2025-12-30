import Foundation

/// Errors that can occur when interacting with the NHL API
public enum NHLAPIError: Error, Sendable {
    /// The requested resource was not found (HTTP 404)
    case resourceNotFound(message: String)

    /// Rate limit exceeded (HTTP 429)
    case rateLimitExceeded

    /// Server error (HTTP 5xx)
    case serverError(statusCode: Int, message: String)

    /// Bad request (HTTP 400)
    case badRequest(message: String)

    /// Unauthorized request (HTTP 401/403)
    case unauthorized(message: String)

    /// API returned an unexpected error
    case apiError(statusCode: Int, message: String)

    /// HTTP request failed
    case requestError(underlying: Error)

    /// JSON decoding/encoding failed
    case jsonError(underlying: Error)

    /// Any other error
    case other(message: String)
}

extension NHLAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .resourceNotFound(let message):
            return "Resource not found: \(message)"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .unauthorized(let message):
            return "Unauthorized: \(message)"
        case .apiError(let statusCode, let message):
            return "API error (\(statusCode)): \(message)"
        case .requestError(let underlying):
            return "Request failed: \(underlying.localizedDescription)"
        case .jsonError(let underlying):
            return "JSON error: \(underlying.localizedDescription)"
        case .other(let message):
            return message
        }
    }
}
