@testable import deezer_api_app

extension Array where Element == Album {

    static var stubbedAlbums: [Album] {
        [
            .init(id: 128, title: "Garage Inc."),
            .init(id: 256, title: "S&M"),
            .init(id: 1024, title: "Master Of Puppets")
        ]
    }

}
