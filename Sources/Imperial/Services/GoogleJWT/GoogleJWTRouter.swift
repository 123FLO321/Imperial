import Foundation
import OpenCrypto
import Vapor
import JWTKit

public final class GoogleJWTRouter: FederatedServiceRouter {
    public var tokens: FederatedServiceTokens
    public var callbackCompletion: (Request, String) throws -> (EventLoopFuture<ResponseEncodable>)
    public var scope: [String] = []
    public var callbackURL: String
    public var accessTokenURL: String = "https://www.googleapis.com/oauth2/v4/token"
    public var authURL: String
    
    public init(callback: String, completion: @escaping (Request, String) throws -> (EventLoopFuture<ResponseEncodable>)) throws {
        self.tokens = try GoogleJWTAuth()
        self.callbackURL = callback
        self.authURL = callback
        self.callbackCompletion = completion
    }
    
    public func authURL(_ request: Request) throws -> String {
        return authURL
    }
    
    public func fetchToken(from request: Request) throws -> EventLoopFuture<String> {
//        let headers: HTTPHeaders = ["Content-Type": MediaType.urlEncodedForm.description]
//        let token = try self.jwt()
//        let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(token)"
//
//        return try request.make(Client.self).post(self.accessTokenURL, headers: headers) { $0.body = HTTPBody(string: body) }.flatMap(to: GoogleJWTResponse.self) { response in
//            if response.status == .ok {
//                return try JSONDecoder().decode(GoogleJWTResponse.self, from: response, maxSize: 65_536, on: request)
//            } else { throw Abort(.internalServerError) }
//        }.map { $0.accessToken }
        fatalError()
    }
    
    public func callback(_ request: Request) throws -> EventLoopFuture<Response> {
//        return try self.fetchToken(from: request).flatMap { token in
//            let session = try request.session
//
//            session.setAccessToken(token)
//            try session.set("access_token_service", to: OAuthService.googleJWT)
//
//            return try self.callbackCompletion(request, token)
//        }.flatMap(to: Response.self) { body in
//            return try body.encode(for: request)
//        }
        fatalError()
    }
    
    public func authenticate(_ request: Request) throws -> EventLoopFuture<Response> {
        let redirect: Response = request.redirect(to: self.callbackURL)
        return request.eventLoop.makeSucceededFuture(redirect)
    }
    
    public func jwt() throws -> String {
        let payload = GoogleJWTPayload(
            iss: IssuerClaim(value: self.tokens.clientID),
            scope: self.scope.joined(separator: " "),
            aud: AudienceClaim(value: "https://www.googleapis.com/oauth2/v4/token"),
            iat: IssuedAtClaim(value: Date()),
            exp: ExpirationClaim(value: Date().addingTimeInterval(3600))
        )
        
        let pk = try RSAKey.private(pem: self.tokens.clientSecret.bytes)
        let signer = JWTSigner.rs256(key: pk)
        let jwt = JWT<GoogleJWTPayload>(payload: payload)
        let jwtData = try jwt.sign(using: signer)
        return String(data: Data(jwtData), encoding: .utf8)!
    }
}
