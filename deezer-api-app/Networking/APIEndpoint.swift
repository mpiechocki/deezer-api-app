import Foundation

enum APIEndpoint {
    case search(query: String)
    case artist
}

extension APIEndpoint {

    var path: String {
        let path: String
        switch self {
        case .search:
            path = "/search/artist"
        case .artist:
            path = "/artist"
        }

        return path
    }

    var queryItems: [URLQueryItem]? {
        let queryItems: [URLQueryItem]?

        switch self {
        case .search(let query):
            queryItems = [URLQueryItem(name: "q", value: query)]
        case .artist:
            queryItems = nil
        }

        return queryItems
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.deezer.com"
        components.path = self.path
        if let queryItems = self.queryItems {
            components.queryItems = queryItems
        }

        return components.url
    }

}
