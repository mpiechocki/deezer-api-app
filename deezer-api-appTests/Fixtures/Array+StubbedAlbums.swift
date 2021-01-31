@testable import deezer_api_app

extension Array where Element == Album {

    static var stubbedAlbums: [Album] {
        [
            .init(id: 128, title: "Garage Inc.", coverMedium: "https://url.to/128.jpg", coverXl: "https://url.to/257.jpg"),
            .init(id: 256, title: "S&M", coverMedium: "https://url.to/256.jpg", coverXl: "https://url.to/512.jpg"),
            .init(id: 1024, title: "Master Of Puppets", coverMedium: "https://url.to/1024.jpg", coverXl: "https://url.to/2048.jpg")
        ]
    }

}
