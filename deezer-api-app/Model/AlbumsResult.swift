struct AlbumsResult: Decodable, Equatable {
    let data: [Album]
    let total: Int
}
