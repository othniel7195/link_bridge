//
//  FlutterToolExt.swift
//  link_bridge
//
//  Created by jimmy on 2022/1/8.
//

import Foundation

extension Dictionary {
    func stringify() -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return "Failed to stringify dictionary as json."
    }
}


extension Encodable {
    func dictionaryRepresentation() -> [String: Any] {
        if let data = try? JSONEncoder().encode(self),
           let obj = try? JSONSerialization.jsonObject(with: data),
           let dict = obj as? [String: Any] {
            return dict
        } else {
            return [:]
        }
    }
}


extension String {
    func mapJSONObject<T>(_ type: T.Type) throws -> T where T: Decodable {
        guard let data = self.data(using: .utf8) else {
            throw NSError(domain: "mapJson", code: -1, userInfo: ["details": self])
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
