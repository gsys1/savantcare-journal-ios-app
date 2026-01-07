import Foundation

struct User: Codable {
    let id: Int  // Changed from String to Int
    let publicUniqueId: String
    let facebookID: String?
    let emailAddress: String
    let password: String?
    let wikiUid: String?
    let firstName: String?
    let lastName: String?
    let fullname: String?
    let role: String?
    let companyID: Int?  // Changed from String to Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case publicUniqueId = "publicUniqueId"
        case facebookID = "facebookID"
        case emailAddress = "emailAddress"
        case password
        case wikiUid = "wikiUid"
        case firstName = "firstName"
        case lastName = "lastName"
        case fullname = "fullname"
        case role
        case companyID = "companyID"
    }
}

struct LoginRequest: Codable {
    let emailAddress: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let data: UserData  // Changed back to UserData
}

struct UserData: Codable {
    let user: User
}