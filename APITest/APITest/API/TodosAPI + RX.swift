//
//  TodosAPI + Closure.swift
//  APITest
//
//  Created by 황원상 on 4/22/24.
//

import Foundation
import MultipartForm
import RxSwift
import RxCocoa

extension TodosAPI {
    static func fetchTodosWithObservableResult(page: Int = 1) -> Observable<(Result<BaseListResponse<Todo>, APIError>)> {
        
        let urlString = baseURL + "todos" + "?page=\(page)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { resp, data in
                
                guard let httpResponse = resp as? HTTPURLResponse else {
                    return .failure(.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 401:
                    return .failure(.unauthorized)
                default:
                    print(123)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    return .failure(.badStatus(code: httpResponse.statusCode))
                }
                
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let modelObject = topLevelModel.data
                    
                    // 상태코드는 200인데 파싱한 데이터에 따라 에러처리
                    guard let todos = modelObject,
                          !todos.isEmpty else {
                        return .failure(.noContent)
                    }
                    
                    return .success(topLevelModel)
                    
                } catch {
                    return .failure(APIError.decodingError)
                }
            }
    }
    
    
    static func fetchTodosWithObservable(page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        
        let urlString = baseURL + "todos" + "?page=\(page)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { resp, data -> BaseListResponse<Todo> in
                
                switch resp.statusCode {
                case 401:
                    throw APIError.unauthorized
                default:
                    print(123)
                }
                
                if !(200...299).contains(resp.statusCode) {
                    throw APIError.badStatus(code: resp.statusCode)
                }
                
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let modelObject = topLevelModel.data
                    
                    // 상태코드는 200인데 파싱한 데이터에 따라 에러처리
                    guard let todos = modelObject,
                          !todos.isEmpty else {
                        throw APIError.noContent
                    }
                    return topLevelModel
                    
                } catch {
                    throw APIError.decodingError
                }
            }
    }
    
    
    static func fetchATodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        let urlString = baseURL + "todos" + "/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { response, data -> BaseResponse<Todo> in
                
                switch response.statusCode {
                case 401:
                    throw APIError.unauthorized
                case 204:
                    throw APIError.noContent
                default:
                    print(123)
                }
                
                if !(200...299).contains(response.statusCode) {
                    throw APIError.badStatus(code: response.statusCode)
                }
                
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return topLevelModel
                }
                catch {
                    throw APIError.jsonEncoding
                }
            }
    }
    
    static func searchTodosWithObservable(searchTerm: String, page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        
        var urlComponents = URLComponents(string: baseURL + "/todos/search")!
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = urlComponents.url else {
            return Observable.error(APIError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { response, data in
                
                switch response.statusCode {
                case 401:
                    throw APIError.unauthorized
                case 204:
                    throw APIError.noContent
                default:
                    print(123)
                }
                
                if !(200...299).contains(response.statusCode) {
                    throw APIError.notAllowedUrl
                }
                
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let modelObject = topLevelModel.data
                    
                    guard let todos = modelObject,
                          !todos.isEmpty else {
                        throw APIError.noContent
                    }
                    return topLevelModel
                } catch {
                    throw APIError.decodingError
                }
            }
    }
    
    static func addATodoWithObservable(title: String, isDone:Bool = false) -> Observable<BaseResponse<Todo>> {
        let urlString = baseURL + "todos"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = form.bodyData
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { response, data in
                switch response.statusCode {
                case 401:
                    throw APIError.notAllowedUrl
                case 204:
                    throw APIError.noContent
                default:
                    print(123)
                }
                
                if !(200...299).contains(response.statusCode) {
                    throw APIError.notAllowedUrl
                }
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return topLevelModel
                } catch {
                    throw APIError.decodingError
                }
            }
    }
    
    static func addATodoJsonWithObservable(title: String, isDone:Bool = false) -> Observable<BaseResponse<Todo>> {
        let urlString = baseURL + "todos-json"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String : Any] = ["title": title, "is_done": "\(isDone)"]
        
        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else {
            return Observable.error(APIError.jsonEncoding)
        }
        
        urlRequest.httpBody = data
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { httpResponse, data in
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.badStatus(code: 401)
                case 204:
                    throw APIError.noContent
                default:
                    print(123)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.notAllowedUrl
                }
                
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return topLevelModel
                    
                } catch {
                    throw APIError.jsonEncoding
                }
            }
    }
    
    static func editTodoJsonWithObservable(id: Int,
                                           title: String,
                                           isDone:Bool = false) -> Observable<BaseResponse<Todo>> {
        let urlString = baseURL + "todos-json/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String : Any] = ["title": title, "is_done": "\(isDone)"]
        
        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else {
            return Observable.error(APIError.decodingError)
        }
        
        urlRequest.httpBody = data
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { httpResponse, jsonData in
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.badStatus(code: 401)
                case 204:
                    throw APIError.noContent
                default:
                    print(123)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.notAllowedUrl
                }
                
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    return topLevelModel
                    
                } catch {
                    throw APIError.jsonEncoding
                }
            }
    }
    
    static func editTodoWithObservable(id: Int,
                                       title: String,
                                       isDone:Bool = false) -> Observable<BaseResponse<Todo>> {
        let urlString = baseURL + "todos-json/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String : String] = ["title": title, "is_done": "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else {
            return Observable.error(APIError.decodingError)
        }
        
        urlRequest.httpBody = data
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { httpResponse, jasonData in
            
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.badStatus(code: 401)
                case 204:
                    throw APIError.noContent
                default:
                    print(123)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.notAllowedUrl
                }
                
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
                    return topLevelModel
                    
                } catch {
                    throw APIError.decodingError
                }
            }
    }
    
    static func deleteATodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        let urlString = baseURL + "todos-json/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map{ httpResponse, jasonData in
                switch httpResponse.statusCode {
                case 401:
                    throw APIError.badStatus(code: 401)
                case 204:
                    throw APIError.noContent
                default:
                    print(123)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.notAllowedUrl
                }
                
                    do {
                        let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
                        return topLevelModel
                    } catch {
                        throw APIError.decodingError
                    }
            }
    }
    
    static func addATodoAndFetchTodosWithObservable(title: String,
                                                    isDone: Bool,
                                                    completion: @escaping  (Result<BaseListResponse<Todo>, APIError>) -> Void) {
        self.addATodo(title: title) { result in
            switch result {
            case .success(_):
                self.fetchTodos { result in
                    switch result {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let err):
                        completion(.failure(err))
                    }
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    static func adding(title: String, isDone:Bool) -> Observable<BaseListResponse<Todo>> {
        return addATodoWithObservable(title: title)
            .flatMap { _ in fetchTodosWithObservable() }
    }
    // api 동시처리, 선택된 것들 일괄삭제 api 요청, completion-> 삭제 된 것들
    static func deleteSelectedTodosWithObservable(selectedTodoIds: [Int], completion: @escaping ([Int]) -> Void) {
        let group = DispatchGroup()
        
        // 성공적인 삭제
        var deletedTodoIds: [Int] = []
        
        selectedTodoIds.forEach { aTodoId in
            group.enter()
            
            self.deleteATodo(id: aTodoId) { result in
                switch result {
                case .success(let resp):
                    if let todoId = resp.data?.id {
                        deletedTodoIds.append(todoId)
                    }
                case .failure(let err):
                    print("inner failure.")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(deletedTodoIds)
        }
    }
    
    // 선택된 할일 가져오기, 에러 났을때 completion
    static func fetchSelectedTodosWithObservable(selectedTodoIds: [Int], completion: @escaping (Result<[Todo], APIError>) -> Void) {
        let group = DispatchGroup()
        
        // 성공적인 삭제
        var fetchedTodoIds: [Todo] = []
        // 중간에 생긴 에러
        var apiErrors: [APIError] = []
        
        var apiResult = [Int:Result<BaseResponse<Todo>, APIError>]()
        
        selectedTodoIds.forEach { aTodoId in
            group.enter()
            
            self.fetchATodo(id: aTodoId) { result in
                switch result {
                case .success(let resp):
                    if let todoId = resp.data {
                        fetchedTodoIds.append(todoId)
                    }
                case .failure(let err):
                    print("inner failure.")
                    apiErrors.append(err)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if !apiErrors.isEmpty {
                if let err = apiErrors.first {
                    completion(.failure(err))
                    return
                }
            }
            completion(.success(fetchedTodoIds))
        }
    }
}
