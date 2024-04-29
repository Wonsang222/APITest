//
//  TodosAPI + Async.swift
//  APITest
//
//  Created by 황원상 on 4/28/24.
//

import Foundation
import Combine
import MultipartForm

extension TodosAPI {
    
    // Result를 쓰면 throws안쓴다. -> result에 포함되어 있기 때무네
    static func fetchTodosWithAsync(page: Int = 1) async throws ->
    BaseListResponse<Todo> {
        
        let urlString = baseURL + "todos" + "?page=\(page)"
        guard let url = URL(string: urlString) else {
            throw APIError.unknown(nil)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, resp) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = resp as? HTTPURLResponse else {
                throw APIError.notAllowedUrl
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw APIError.unauthorized
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                throw APIError.badStatus(code: httpResponse.statusCode)
            }

                let topLevelModel = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                
                return topLevelModel
            }
        catch {
            if let err = error as? DecodingError {
                throw APIError.decodingError
            }
            throw APIError.unknown(nil)
        }

    }
    
//    static func fetchTodosWithPublisher(page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, APIError> {
//        
//        let urlString = baseURL + "todos" + "?page=\(page)"
//        guard let url = URL(string: urlString) else {
//            return Fail(error: APIError.notAllowedUrl).eraseToAnyPublisher()
//        }
//        
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
//        
//        return URLSession.shared.dataTaskPublisher(for: urlRequest)
//            .tryMap({ (data: Data, response: URLResponse) in
//                let resp = response as! HTTPURLResponse
//                switch resp.statusCode {
//                case 401:
//                    throw APIError.unauthorized
//                default:
//                    print(123)
//                }
//                
//                if !(200...299).contains(resp.statusCode) {
//                    throw APIError.badStatus(code: resp.statusCode)
//                }
//                return data
//            })
//            .decode(type: BaseListResponse<Todo>.self, decoder: JSONDecoder())
//            .tryMap { modelObject in
//                guard let todos = modelObject.data,
//                      !todos.isEmpty else {
//                    throw APIError.noContent
//                }
//                return modelObject
//            }
//            .mapError({ err -> APIError in
//                if let error = err as? APIError {
//                    return error
//                }
//                
//                if let error = err as? DecodingError {  // decoding 에러라면
//                    return APIError.decodingError
//                }
//                return APIError.unknown(nil)
//            })
//            .eraseToAnyPublisher()
// 
//    }
//    
//    
    static func fetchATodoWithAsync(id: Int) async throws -> BaseResponse<Todo> {
        let urlString = baseURL + "todos" + "/\(id)"
        guard let url = URL(string: urlString) else {
            throw APIError.unknown(nil)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, resp) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = resp as? HTTPURLResponse else {
                throw APIError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw APIError.notAllowedUrl
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                throw APIError.badStatus(code: httpResponse.statusCode)
            }

                let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            return topLevelModel
            }
        catch {
            if let err = error as? DecodingError {
                throw APIError.decodingError
            }
            // 이런식으로도 할 수 있다.  // 이 안에서 에러를 변경하는거임
            // do catch 로 잡아서 밖으로던지는 방법
            // 다만 에러 타입이 명시되지 않는다라는 단점이 있다.
            // rx와 동일
            if let err = error as? URLError {
                throw APIError.badStatus(code: err.errorCode)
            }
            throw APIError.unknown(nil)
        }
    }
////
//    static func searchTodosWithPublisher(searchTerm: String, page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, APIError> {
//        
//        var urlComponents = URLComponents(string: baseURL + "/todos/search")!
//        urlComponents.queryItems = [
//            URLQueryItem(name: "query", value: searchTerm),
//            URLQueryItem(name: "page", value: "\(page)")
//        ]
//        
//        guard let url = urlComponents.url else {
//            return Fail(error: APIError.unknown(nil)).eraseToAnyPublisher()
//        }
//        
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
//        
//        return URLSession.shared.dataTaskPublisher(for: urlRequest)
//            .tryMap({ (data: Data, response: URLResponse) in
//                let response = response as! HTTPURLResponse
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
//                return data
//            })
//            .decode(type: BaseListResponse<Todo>.self, decoder: JSONDecoder())
//            .mapError({ err in
//                if let error = err as? DecodingError {
//                    return APIError.decodingError
//                }
//                return APIError.unknown(nil)
//            })
//            .eraseToAnyPublisher()
//    }
////
    static func addATodoWithAsync(title: String, isDone:Bool = false) async throws -> BaseResponse<Todo> {
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
        do {
            let (data, resp) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = resp as? HTTPURLResponse else {
                throw APIError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw APIError.notAllowedUrl
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                throw APIError.badStatus(code: httpResponse.statusCode)
            }

                let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            return topLevelModel
            
        }
        catch {
            if let err = error as? DecodingError {
                throw APIError.decodingError
            }
            // 이런식으로도 할 수 있다.  // 이 안에서 에러를 변경하는거임
            // do catch 로 잡아서 밖으로던지는 방법
            // 다만 에러 타입이 명시되지 않는다라는 단점이 있다.
            // rx와 동일
            if let err = error as? URLError {
                throw APIError.badStatus(code: err.errorCode)
            }
            throw APIError.unknown(nil)
        }
    }
//    
////    static func addATodoJsonWithPublisher(title: String, isDone:Bool = false) -> AnyPublisher<BaseResponse<Todo>, APIError> {
////        let urlString = baseURL + "todos-json"
////        let url = URL(string: urlString)!
////        var urlRequest = URLRequest(url: url)
////        urlRequest.httpMethod = "POST"
////        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
////        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
////
////        let requestParams: [String : Any] = ["title": title, "is_done": "\(isDone)"]
////
////        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else {
////            return Observable.error(APIError.jsonEncoding)
////        }
////
////        urlRequest.httpBody = data
////
////        return URLSession.shared.rx.response(request: urlRequest)
////            .map { httpResponse, data in
////                switch httpResponse.statusCode {
////                case 401:
////                    throw APIError.badStatus(code: 401)
////                case 204:
////                    throw APIError.noContent
////                default:
////                    print(123)
////                }
////
////                if !(200...299).contains(httpResponse.statusCode) {
////                    throw APIError.notAllowedUrl
////                }
////
////                do {
////                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
////                    return topLevelModel
////
////                } catch {
////                    throw APIError.jsonEncoding
////                }
////            }
////    }
////
////    static func editTodoJsonWithPublisher(id: Int,
////                                          title: String,
////                                          isDone:Bool = false) -> Observable<BaseResponse<Todo>> {
////        let urlString = baseURL + "todos-json/\(id)"
////        let url = URL(string: urlString)!
////        var urlRequest = URLRequest(url: url)
////        urlRequest.httpMethod = "POST"
////        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
////        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
////
////        let requestParams: [String : Any] = ["title": title, "is_done": "\(isDone)"]
////
////        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else {
////            return Observable.error(APIError.decodingError)
////        }
////
////        urlRequest.httpBody = data
////
////        return URLSession.shared.rx.response(request: urlRequest)
////            .map { httpResponse, jsonData in
////                switch httpResponse.statusCode {
////                case 401:
////                    throw APIError.badStatus(code: 401)
////                case 204:
////                    throw APIError.noContent
////                default:
////                    print(123)
////                }
////
////                if !(200...299).contains(httpResponse.statusCode) {
////                    throw APIError.notAllowedUrl
////                }
////
////                do {
////                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
////                    return topLevelModel
////
////                } catch {
////                    throw APIError.jsonEncoding
////                }
////            }
////    }
////
////    static func editTodoWithPublisher(id: Int,
////                                      title: String,
////                                      isDone:Bool = false) -> Observable<BaseResponse<Todo>> {
////        let urlString = baseURL + "todos-json/\(id)"
////        let url = URL(string: urlString)!
////        var urlRequest = URLRequest(url: url)
////        urlRequest.httpMethod = "PUT"
////        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
////        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
////
////        let requestParams: [String : String] = ["title": title, "is_done": "\(isDone)"]
////
////        urlRequest.percentEncodeParameters(parameters: requestParams)
////
////        guard let data = try? JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted) else {
////            return Observable.error(APIError.decodingError)
////        }
////
////        urlRequest.httpBody = data
////
////        return URLSession.shared.rx.response(request: urlRequest)
////            .map { httpResponse, jasonData in
////
////                switch httpResponse.statusCode {
////                case 401:
////                    throw APIError.badStatus(code: 401)
////                case 204:
////                    throw APIError.noContent
////                default:
////                    print(123)
////                }
////
////                if !(200...299).contains(httpResponse.statusCode) {
////                    throw APIError.notAllowedUrl
////                }
////
////                do {
////                    let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jasonData)
////                    return topLevelModel
////
////                } catch {
////                    throw APIError.decodingError
////                }
////            }
////    }
////
    static func deleteATodoWithAsync(id: Int) async throws ->
    BaseResponse<Todo> {
        let urlString = baseURL + "todos-json/\(id)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, resp) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = resp as? HTTPURLResponse else {
                throw APIError.unknown(nil)
            }
            
            switch httpResponse.statusCode {
            case 401:
                throw APIError.notAllowedUrl
            default:
                print(123)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                throw APIError.badStatus(code: httpResponse.statusCode)
            }

                let topLevelModel = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            return topLevelModel
            
        }
        catch {
            if let err = error as? DecodingError {
                throw APIError.decodingError
            }
            // 이런식으로도 할 수 있다.  // 이 안에서 에러를 변경하는거임
            // do catch 로 잡아서 밖으로던지는 방법
            // 다만 에러 타입이 명시되지 않는다라는 단점이 있다.
            // rx와 동일
            if let err = error as? URLError {
                throw APIError.badStatus(code: err.errorCode)
            }
            throw APIError.unknown(nil)
        }
    }
////
    static func addATodoAndFetchTodosWithAsync(title: String, isDone:Bool) async throws -> [Todo] {
        // do catch를 쓸 필요가 없는 이유. 함수 밖으로 던진다
        // catch로 error를 바꿀 수 있다.
        let firstResult = try await addATodoWithAsync(title: title)
        let secondResult = try await fetchTodosWithAsync()
        guard let finalResult = secondResult.data else {
            throw APIError.noContent
        }
        return finalResult
    }
//    
//    static func addATodoAndFetchTodosWithPublisherWithNoError2(title: String, isDone:Bool) -> AnyPublisher<[Todo], Never> {
//        return addATodoWithPublisher(title: title, isDone: isDone)
//            .map { _ in self.fetchTodosWithPublisher()}
//            .switchToLatest()  //  flatmapLatest == map + switchLatest
//            .compactMap { $0.data}
//                .catch({ _ in Just([]).eraseToAnyPublisher()})
//                .replaceError(with: [])  // catch와 같은 방법이다.  이렇게 intercept를 하면 에러 타입은 never
//            .eraseToAnyPublisher()
//    }
////
//    // api 동시처리, 선택된 것들 일괄삭제 api 요청, completion-> 삭제 된 것들
//    //merge의 경우엔 문제가 되는 부분이 있따. merge 요소중 하나라도 error가 나면 스트림 전체가 종료. 그러므로 error type을 never로 하고 catch 하는게 나음.
//    static func deleteSelectedTodosWithPublisher(selectedTodoIds: [Int]) -> AnyPublisher<Int, Never> {
//        let apiCall = selectedTodoIds.map { id -> AnyPublisher<Int?, Never> in
//            return self.deleteATodoWithPublisher(id: id)
//                .map { $0.data?.id }
//                .replaceError(with: nil)
//                .eraseToAnyPublisher()
//        }
//        return Publishers.MergeMany(apiCall)
//            .compactMap {$0}
//            .eraseToAnyPublisher()
//    }
////
////
    static func deleteSelectedTodosWithAsync(selectedTodoIds: [Int]) async -> [Int] {
        
        // 에러 안던지는 타입으로 한거임
        async let firstResult = self.deleteATodoWithAsync(id: 1641)
        async let secondResult = self.deleteATodoWithAsync(id: 1648)
        async let thirdResult = self.deleteATodoWithAsync(id: 1649)
        do{
            let results = try await [firstResult.data?.id, secondResult.data?.id, thirdResult.data?.id]
            return results.compactMap { $0 }
        }
        catch {
            return []
        }
    }
    
    
    // withTaskgroup
    // withTaskThrowinggroup
    static func deleteSelectedTodosWithAsyncTaskGroupWithError(selectedTodoIds: [Int]) async throws -> [Int] {
        
       await withThrowingTaskGroup(of: Int?.self) { group in
            for id in selectedTodoIds {
                group.addTask {
                    // 단일 api 쏘기
                    let childTaskResult = try await self.deleteATodoWithAsync(id: id)
                    return childTaskResult.data?.id
                }
            }
           var deletedTodoIds = [Int]()
           
           for try await singleValue in group {
               if let value = singleValue {
                   deletedTodoIds.append(value)
               }
           }
        }
        
    }
}
