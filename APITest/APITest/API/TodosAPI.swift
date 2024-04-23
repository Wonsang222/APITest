//
//  TodosAPI.swift
//  APITest
//
//  Created by 황원상 on 4/22/24.
//

import Foundation
import MultipartForm

enum TodosAPI {
    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v2/"
    
    enum APIError: Error {
        case noContent
        case decodingError
        case badStatus(code: Int)
        case unknown(_ err: Error?)
        case unauthorized
        case notAllowedUrl
        case jsonEncoding
        
        var info: String {
            switch self {
            case .noContent: return "데이터가 없습니다."
            case .decodingError: return "디코딩 에러입니다."
            case .unauthorized: return "인증되지 않은 사용자입니다."
            case .badStatus(code: let code): return "에러입니다. 상태코드 \(code)"
            case .unknown(let err): return "알수없는 에러 입니다."
            case .notAllowedUrl: return "wrong url"
            case .jsonEncoding: return "not valid json type"
            }
        }
    }
    
   
}
