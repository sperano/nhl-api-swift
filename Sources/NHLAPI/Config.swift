import Foundation

/// Configuration options for the NHL API client
public struct ClientConfig: Sendable {
    /// Request timeout in seconds
    public let timeout: TimeInterval

    /// Whether to verify SSL certificates (primarily for testing)
    public let sslVerify: Bool

    /// Whether to follow HTTP redirects
    public let followRedirects: Bool

    /// Creates a new client configuration
    /// - Parameters:
    ///   - timeout: Request timeout in seconds (default: 10)
    ///   - sslVerify: Whether to verify SSL certificates (default: true)
    ///   - followRedirects: Whether to follow HTTP redirects (default: true)
    public init(
        timeout: TimeInterval = 10,
        sslVerify: Bool = true,
        followRedirects: Bool = true
    ) {
        self.timeout = timeout
        self.sslVerify = sslVerify
        self.followRedirects = followRedirects
    }

    /// Default configuration
    public static let `default` = ClientConfig()
}
