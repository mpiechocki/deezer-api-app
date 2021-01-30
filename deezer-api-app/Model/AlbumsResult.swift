struct AlbumsResult: Decodable {
    let data: [Album]
    let total: Int
    let next: String
}
