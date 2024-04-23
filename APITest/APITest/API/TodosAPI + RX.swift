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
    static func fetchTodosWithObservable(page: Int = 1) -> Observable<(Result<BaseListResponse<Todo>, APIError>)> {
        
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
    
    static func fetchATodoWithObservable(id: Int, completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        let urlString = baseURL + "todos" + "/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, resp, err in
            
            if let error = err {
                return completion(.failure(.unknown(error)))
            }
        
            guard let httpResponse = resp as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
        
            if let jasonData = data {
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
                    
                    completion(.success(topLevelModel))
                    
                } catch {
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    static func searchTodosWithObservable(searchTerm: String, page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, APIError>) -> Void) {

        var urlComponents = URLComponents(string: baseURL + "/todos/search")!
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "page", value: "\(page)")
        ]
      
        guard let url = urlComponents.url else { return completion(.failure(.notAllowedUrl))}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, resp, err in
            
            if let error = err {
                return completion(.failure(.unknown(error)))
            }
        
            guard let httpResponse = resp as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
        
            if let jasonData = data {
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jasonData)
                    let modelObject = topLevelModel.data
                    
                    // 상태코드는 200인데 파싱한 데이터에 따라 에러처리
                    guard let todos = modelObject,
                          !todos.isEmpty else {
                        return completion(.failure(.noContent))
                    }
                    
                    completion(.success(topLevelModel))
                    
                } catch {
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    static func addATodoWithObservable(title: String, isDone:Bool = false, completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
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
        
        URLSession.shared.dataTask(with: urlRequest) { data, resp, err in
            
            if let error = err {
                return completion(.failure(.unknown(error)))
            }
        
            guard let httpResponse = resp as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
        
            if let jasonData = data {
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
                    
                    completion(.success(topLevelModel))
                    
                } catch {
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    static func addATodoJsonWithObservable(title: String, isDone:Bool = false, completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        let urlString = baseURL + "todos-json"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        let requestParams: [String : Any] = ["title": title, "is_done": "\(isDone)"]
        
        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else { return }
    
        urlRequest.httpBody = data
        
        URLSession.shared.dataTask(with: urlRequest) { data, resp, err in
            
            if let error = err {
                return completion(.failure(.unknown(error)))
            }
        
            guard let httpResponse = resp as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
        
            if let jasonData = data {
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
                    
                    completion(.success(topLevelModel))
                    
                } catch {
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    static func editTodoJsonWithObservable(id: Int,
                             title: String,
                             isDone:Bool = false,
                             completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        let urlString = baseURL + "todos-json/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        let requestParams: [String : Any] = ["title": title, "is_done": "\(isDone)"]
        
        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else { return }
    
        urlRequest.httpBody = data
        
        URLSession.shared.dataTask(with: urlRequest) { data, resp, err in
            
            if let error = err {
                return completion(.failure(.unknown(error)))
            }
        
            guard let httpResponse = resp as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
        
            if let jasonData = data {
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
                    
                    completion(.success(topLevelModel))
                    
                } catch {
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    static func editTodoWithObservable(id: Int,
                             title: String,
                             isDone:Bool = false,
                             completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        let urlString = baseURL + "todos-json/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
        let requestParams: [String : String] = ["title": title, "is_done": "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else { return }
    
        urlRequest.httpBody = data
        
        URLSession.shared.dataTask(with: urlRequest) { data, resp, err in
            
            if let error = err {
                return completion(.failure(.unknown(error)))
            }
        
            guard let httpResponse = resp as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
        
            if let jasonData = data {
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
                    
                    completion(.success(topLevelModel))
                    
                } catch {
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
    }
    
    static func deleteATodoWithObservable(id: Int,
                             completion: @escaping (Result<BaseResponse<Todo>, APIError>) -> Void) {
        let urlString = baseURL + "todos-json/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")

        URLSession.shared.dataTask(with: urlRequest) { data, resp, err in
            
            if let error = err {
                return completion(.failure(.unknown(error)))
            }
        
            guard let httpResponse = resp as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(.unauthorized))
            case 204:
                return completion(.failure(.noContent))
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(.badStatus(code: httpResponse.statusCode)))
            }
        
            if let jasonData = data {
                do {
                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
                    
                    completion(.success(topLevelModel))
                    
                } catch {
                    completion(.failure(APIError.decodingError))
                }
            }
        }.resume()
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

