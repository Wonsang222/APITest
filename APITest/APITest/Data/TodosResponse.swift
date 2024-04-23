//
//  TodosResponse.swift
//  APITest
//
//  Created by 황원상 on 4/22/24.
//

import Foundation

// MARK: - TodosResponse
struct TodosResponse: Decodable {
    let data: [Todo]?
    let meta: Meta?
    let message: String?
}

struct BaseListResponse<T: Codable>: Decodable {
    let data: [T]?
    let meta: Meta?
    let message: String?
}

struct BaseResponse<T: Codable>: Decodable {
    let data: T?
    let message: String?
}

// MARK: - Datum
struct Todo: Codable {
    let id: Int?
    let title: String?
    let isDone: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Meta
struct Meta: Codable {
    let currentPage, from, lastPage, perPage: Int?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }
}

