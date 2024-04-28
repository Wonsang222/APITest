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
    
    static func fetchTodosWithPublisher(page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, APIError> {
        
        let urlString = baseURL + "todos" + "?page=\(page)"
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.notAllowedUrl).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, response: URLResponse) in
                let resp = response as! HTTPURLResponse
                switch resp.statusCode {
                case 401:
                    throw APIError.unauthorized
                default:
                    print(123)
                }
                
                if !(200...299).contains(resp.statusCode) {
                    throw APIError.badStatus(code: resp.statusCode)
                }
                return data
            })
            .decode(type: BaseListResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap { modelObject in
                guard let todos = modelObject.data,
                      !todos.isEmpty else {
                    throw APIError.noContent
                }
                return modelObject
            }
            .mapError({ err -> APIError in
                if let error = err as? APIError {
                    return error
                }
                
                if let error = err as? DecodingError {  // decoding 에러라면
                    return APIError.decodingError
                }
                return APIError.unknown(nil)
            })
            .eraseToAnyPublisher()
 
    }
    
    
    static func fetchATodoWithPublisher(id: Int) ->
        AnyPublisher<BaseResponse<Todo>, APIError> {
        let urlString = baseURL + "todos" + "/\(id)"
            guard let url = URL(string: urlString) else {
                return Fail(error: APIError.unknown(nil)).eraseToAnyPublisher()
            }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
            return URLSession.shared.dataTaskPublisher(for: urlRequest)
                .tryMap({ (data: Data, response: URLResponse) in
                    let response = response as! HTTPURLResponse
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
                    return data
                })
                .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
                .mapError { err in
                    if let error = err as? DecodingError {
                        return APIError.decodingError
                    }
                    return APIError.unknown(nil)
                }
                .eraseToAnyPublisher()
    }
//    
    static func searchTodosWithPublisher(searchTerm: String, page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, APIError> {
        
        var urlComponents = URLComponents(string: baseURL + "/todos/search")!
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = urlComponents.url else {
            return Fail(error: APIError.unknown(nil)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, response: URLResponse) in
                let response = response as! HTTPURLResponse
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
                return data
            })
            .decode(type: BaseListResponse<Todo>.self, decoder: JSONDecoder())
            .mapError({ err in
                if let error = err as? DecodingError {
                    return APIError.decodingError
                }
                return APIError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
//    
    static func addATodoWithPublisher(title: String, isDone:Bool = false) -> AnyPublisher<BaseResponse<Todo>, APIError> {
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
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, response: URLResponse) in
                let response = response as! HTTPURLResponse
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
                return data
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .mapError({ err in
                if let error = err as? DecodingError {
                    return APIError.decodingError
                }
                return APIError.unknown(nil)
            })
            .eraseToAnyPublisher()

    }
    
//    static func addATodoJsonWithPublisher(title: String, isDone:Bool = false) -> AnyPublisher<BaseResponse<Todo>, APIError> {
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
    static func deleteATodoWithPublisher(id: Int) ->
    AnyPublisher<BaseResponse<Todo>, APIError> {
        let urlString = baseURL + "todos-json/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, response: URLResponse) in
                let httpResponse = response as! HTTPURLResponse
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
                return data
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .mapError({ err in
                if let err = err as? DecodingError {
                    return APIError.decodingError
                }
                return APIError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
//    
    static func addATodoAndFetchTodosWithPublisher(title: String, isDone:Bool) -> AnyPublisher<[Todo], APIError> {
        return addATodoWithPublisher(title: title, isDone: isDone)
            .flatMap { _ in self.fetchTodosWithPublisher()}
            .compactMap { $0.data}
//            .catch({ _ in Just([]).eraseToAnyPublisher()})
//            .replaceError(with: [])  // catch와 같은 방법이다.  이렇게 intercept를 하면 에러 타입은 never
            .mapError({ err in
                if let err = err as? DecodingError {
                    return APIError.decodingError
                }
                if let err = err as? APIError {
                    return err
                }
                return APIError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
    
    static func addATodoAndFetchTodosWithPublisherWithNoError2(title: String, isDone:Bool) -> AnyPublisher<[Todo], Never> {
        return addATodoWithPublisher(title: title, isDone: isDone)
            .map { _ in self.fetchTodosWithPublisher()}
            .switchToLatest()  //  flatmapLatest == map + switchLatest
            .compactMap { $0.data}
                .catch({ _ in Just([]).eraseToAnyPublisher()})
                .replaceError(with: [])  // catch와 같은 방법이다.  이렇게 intercept를 하면 에러 타입은 never
            .eraseToAnyPublisher()
    }
//
    // api 동시처리, 선택된 것들 일괄삭제 api 요청, completion-> 삭제 된 것들
    //merge의 경우엔 문제가 되는 부분이 있따. merge 요소중 하나라도 error가 나면 스트림 전체가 종료. 그러므로 error type을 never로 하고 catch 하는게 나음.
    static func deleteSelectedTodosWithPublisher(selectedTodoIds: [Int]) -> AnyPublisher<Int, Never> {
        let apiCall = selectedTodoIds.map { id -> AnyPublisher<Int?, Never> in
            return self.deleteATodoWithPublisher(id: id)
                .map { $0.data?.id }
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        return Publishers.MergeMany(apiCall)
            .compactMap {$0}
            .eraseToAnyPublisher()
    }
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
    
        // zip은 오픈소스 라이브러리 사용
    
//    static func fetchSelectedTodosWithPublisher2(selectedTodoIds: [Int]) -> AnyPublisher<[Todo], Never> {
//        
//        let apiCall = selectedTodoIds.map { id in
//            return self.fetchATodoWithPublisher(id: id)
//                .map { $0.data }
//                .replaceError(with: nil)
//                .eraseToAnyPublisher()
//        }
//        return Observable.zip(apiCall)
//            .map{ $0.compactMap{$0} }
//    }
//    
}
