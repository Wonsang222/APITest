//
//  URLRequest + Ext.swift
//  APITest
//
//  Created by 황원상 on 4/22/24.
//

import Foundation

extension URLRequest {
    private func percentEscapedString(_ string: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._*")
        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+")
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
    }
    
    mutating func percentEncodeParameters(parameters: [String : String]) {
        let parameterArray = parameters.map{ (arg) -> String in
            let (key, value) = arg
            return "\(key)=\(self.percentEscapedString(value))"
        }
        httpBody = parameterArray.joined(separator: "&").data(using: .utf8)
    }
}
