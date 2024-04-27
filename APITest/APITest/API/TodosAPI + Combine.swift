//
//  TodosAPI + Combine.swift
//  APITest
//
//  Created by 황원상 on 4/27/24.
//

import Foundation
import Combine
import MultipartForm

extension TodosAPI {
    
    static func fetchTodosWithPublisherResult(page: Int = 1) ->
    AnyPublisher<Result<BaseListResponse<Todo>,APIError>, Never> {
        
        let urlString = baseURL + "todos" + "?page=\(page)"
        guard let url = URL(string: urlString) else {
            return Just(.failure(APIError.notAllowedUrl)).eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map( { data, resp in
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
            })
            .replaceError(with: .failure(APIError.unknown(nil)))
            .eraseToAnyPublisher()
    }
    
    
    static func fetchTodosWithPublisher(page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        
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
    
    
//    static func fetchATodoWithPublisher(id: Int) -> Observable<BaseResponse<Todo>> {
//        let urlString = baseURL + "todos" + "/\(id)"
//        let url = URL(string: urlString)!
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
//        
//        return URLSession.shared.rx.response(request: urlRequest)
//            .map { response, data -> BaseResponse<Todo> in
//                
//                switch response.statusCode {
//                case 401:
//                    throw APIError.unauthorized
//                case 204:
//                    throw APIError.noContent
//                default:
//                    print(123)
//                }
//                
//                if !(200...299).contains(response.statusCode) {
//                    throw APIError.badStatus(code: response.statusCode)
//                }
//                
//                do {
//                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
//                    return topLevelModel
//                }
//                catch {
//                    throw APIError.jsonEncoding
//                }
//            }
//    }
//    
//    static func searchTodosWithPublisher(searchTerm: String, page: Int = 1) -> Observable<BaseListResponse<Todo>> {
//        
//        var urlComponents = URLComponents(string: baseURL + "/todos/search")!
//        urlComponents.queryItems = [
//            URLQueryItem(name: "query", value: searchTerm),
//            URLQueryItem(name: "page", value: "\(page)")
//        ]
//        
//        guard let url = urlComponents.url else {
//            return Observable.error(APIError.notAllowedUrl)
//        }
//        
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
//        
//        return URLSession.shared.rx.response(request: urlRequest)
//            .map { response, data in
//                
//                switch response.statusCode {
//                case 401:
//                    throw APIError.unauthorized
//                case 204:
//                    throw APIError.noContent
//                default:
//                    print(123)
//                }
//                
//                if !(200...299).contains(response.statusCode) {
//                    throw APIError.notAllowedUrl
//                }
//                
//                do {
//                    let topLevelModel = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
//                    let modelObject = topLevelModel.data
//                    
//                    guard let todos = modelObject,
//                          !todos.isEmpty else {
//                        throw APIError.noContent
//                    }
//                    return topLevelModel
//                } catch {
//                    throw APIError.decodingError
//                }
//            }
//    }
//    
//    static func addATodoWithPublisher(title: String, isDone:Bool = false) -> Observable<BaseResponse<Todo>> {
//        let urlString = baseURL + "todos"
//        let url = URL(string: urlString)!
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
//        
//        let form = MultipartForm(parts: [
//            MultipartForm.Part(name: "title", value: title),
//            MultipartForm.Part(name: "is_done", value: "\(isDone)")
//        ])
//        
//        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
//        
//        urlRequest.httpBody = form.bodyData
//        
//        return URLSession.shared.rx.response(request: urlRequest)
//            .map { response, data in
//                switch response.statusCode {
//                case 401:
//                    throw APIError.notAllowedUrl
//                case 204:
//                    throw APIError.noContent
//                default:
//                    print(123)
//                }
//                
//                if !(200...299).contains(response.statusCode) {
//                    throw APIError.notAllowedUrl
//                }
//                do {
//                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
//                    return topLevelModel
//                } catch {
//                    throw APIError.decodingError
//                }
//            }
//    }
//    
//    static func addATodoJsonWithPublisher(title: String, isDone:Bool = false) -> Observable<BaseResponse<Todo>> {
//        let urlString = baseURL + "todos-json"
//        let url = URL(string: urlString)!
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let requestParams: [String : Any] = ["title": title, "is_done": "\(isDone)"]
//        
//        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else {
//            return Observable.error(APIError.jsonEncoding)
//        }
//        
//        urlRequest.httpBody = data
//        
//        return URLSession.shared.rx.response(request: urlRequest)
//            .map { httpResponse, data in
//                switch httpResponse.statusCode {
//                case 401:
//                    throw APIError.badStatus(code: 401)
//                case 204:
//                    throw APIError.noContent
//                default:
//                    print(123)
//                }
//                
//                if !(200...299).contains(httpResponse.statusCode) {
//                    throw APIError.notAllowedUrl
//                }
//                
//                do {
//                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
//                    return topLevelModel
//                    
//                } catch {
//                    throw APIError.jsonEncoding
//                }
//            }
//    }
//    
//    static func editTodoJsonWithPublisher(id: Int,
//                                          title: String,
//                                          isDone:Bool = false) -> Observable<BaseResponse<Todo>> {
//        let urlString = baseURL + "todos-json/\(id)"
//        let url = URL(string: urlString)!
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "POST"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let requestParams: [String : Any] = ["title": title, "is_done": "\(isDone)"]
//        
//        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else {
//            return Observable.error(APIError.decodingError)
//        }
//        
//        urlRequest.httpBody = data
//        
//        return URLSession.shared.rx.response(request: urlRequest)
//            .map { httpResponse, jsonData in
//                switch httpResponse.statusCode {
//                case 401:
//                    throw APIError.badStatus(code: 401)
//                case 204:
//                    throw APIError.noContent
//                default:
//                    print(123)
//                }
//                
//                if !(200...299).contains(httpResponse.statusCode) {
//                    throw APIError.notAllowedUrl
//                }
//                
//                do {
//                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
//                    return topLevelModel
//                    
//                } catch {
//                    throw APIError.jsonEncoding
//                }
//            }
//    }
//    
//    static func editTodoWithPublisher(id: Int,
//                                      title: String,
//                                      isDone:Bool = false) -> Observable<BaseResponse<Todo>> {
//        let urlString = baseURL + "todos-json/\(id)"
//        let url = URL(string: urlString)!
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "PUT"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
//        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        let requestParams: [String : String] = ["title": title, "is_done": "\(isDone)"]
//        
//        urlRequest.percentEncodeParameters(parameters: requestParams)
//        
//        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else {
//            return Observable.error(APIError.decodingError)
//        }
//        
//        urlRequest.httpBody = data
//        
//        return URLSession.shared.rx.response(request: urlRequest)
//            .map { httpResponse, jasonData in
//                
//                switch httpResponse.statusCode {
//                case 401:
//                    throw APIError.badStatus(code: 401)
//                case 204:
//                    throw APIError.noContent
//                default:
//                    print(123)
//                }
//                
//                if !(200...299).contains(httpResponse.statusCode) {
//                    throw APIError.notAllowedUrl
//                }
//                
//                do {
//                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
//                    return topLevelModel
//                    
//                } catch {
//                    throw APIError.decodingError
//                }
//            }
//    }
//    
//    static func deleteATodoWithPublisher(id: Int) -> Observable<BaseResponse<Todo>> {
//        let urlString = baseURL + "todos-json/\(id)"
//        let url = URL(string: urlString)!
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "DELETE"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
//        
//        return URLSession.shared.rx.response(request: urlRequest)
//            .map{ httpResponse, jasonData in
//                switch httpResponse.statusCode {
//                case 401:
//                    throw APIError.badStatus(code: 401)
//                case 204:
//                    throw APIError.noContent
//                default:
//                    print(123)
//                }
//                
//                if !(200...299).contains(httpResponse.statusCode) {
//                    throw APIError.notAllowedUrl
//                }
//                
//                do {
//                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
//                    return topLevelModel
//                } catch {
//                    throw APIError.decodingError
//                }
//            }
//    }
//    
//    static func addATodoAndFetchTodosWithPublisher(title: String, isDone:Bool) -> Observable<[Todo]> {
//        return addATodoWithObservable(title: title)
//            .flatMapLatest { _ in fetchTodosWithObservable() }
//            .compactMap{ $0.data }
//            .catchAndReturn([])
//            .share(replay: 1)
//    }
//    
//    // api 동시처리, 선택된 것들 일괄삭제 api 요청, completion-> 삭제 된 것들
//    static func deleteSelectedTodosWithPublisher(selectedTodoIds: [Int]) -> Observable<[Int]> {
//        let apiCall = selectedTodoIds.map { id -> Observable<Int?> in
//            return self.deleteATodoWithObservable(id: id)
//                .map { $0.data?.id }
//                .catchAndReturn(nil)
//        }
//        return Observable.zip(apiCall)
//            .map{ $0.compactMap{$0} }
//    }
//    
//    
//    static func deleteSelectedTodosWithPublisher(selectedTodoIds: [Int]) -> Observable<Int> {
//        let apiCall = selectedTodoIds.map { id -> Observable<Int?> in
//            return self.deleteATodoWithObservable(id: id)
//                .map { $0.data?.id }
//                .catchAndReturn(nil)
//        }
//        return Observable.merge(apiCall)
//            .compactMap { $0 }
//    }
//    
//    // 선택된 할일 가져오기, 에러 났을때 completion
//    static func fetchSelectedTodosWithPublisher2(selectedTodoIds: [Int]) -> Observable<[Todo]> {
//        
//        let apiCall = selectedTodoIds.map { id in
//            return self.fetchATodoWithObservable(id: id)
//                .map { $0.data }
//                .catchAndReturn(nil)
//        }
//        return Observable.zip(apiCall)
//            .map{ $0.compactMap{$0} }
//    }
//    
//    static func fetchSelectedTodosWithMerge(selectedTodoIds: [Int]) -> Observable<Todo> {
//        
//        let apiCall = selectedTodoIds.map { id in
//            return self.fetchATodoWithObservable(id: id)
//                .map { $0.data }
//                .catchAndReturn(nil)
//        }
//        return Observable.merge(apiCall)
//            .compactMap { $0 }
//    }
}
