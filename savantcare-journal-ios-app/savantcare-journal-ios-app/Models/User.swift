import Foundation

struct User: Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
    }
}