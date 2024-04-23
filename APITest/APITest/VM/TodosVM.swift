//
//  TodosVM.swift
//  APITest
//
//  Created by 황원상 on 4/22/24.
//

import Foundation
import Combine

class TodosVM: ObservableObject {
    
    init() {

        TodosAPI.addATodo(title: "hahaha", isDone: true) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let resp):
                 print(resp)
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    fileprivate func handleError(_ err: Error) {
        if let err = err as? TodosAPI.APIError {
            switch err {
            case .noContent:
                print(1)
            case .unauthorized:
                print(2)
            default:
                print(3)
            }

        }
    }
}
