import Foundation

enum APIEndpoint: Equatable {
    case search(query: String)
    case albums(artistId: Int, index: Int = 0)
}

extension APIEndpoint {

    var path: String {
        let path: String
        switch self {
        case .search:
            path = "/search/artist"
        case .albums(let artistId, _):
            path = "/artist/\(artistId)/albums"
        }

        return path
    }

    var queryItems: [URLQueryItem]? {
        let queryItems: [URLQueryItem]?

        switch self {
        case .search(let query):
            queryItems = [URLQueryItem(name: "q", value: query)]
        case .albums(_, let index):
            queryItems = [URLQueryItem(name: "index", value: "\(index)")]
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
