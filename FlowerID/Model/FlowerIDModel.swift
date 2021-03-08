//
//  FlowerIDModel.swift
//  FlowerID
//
//  Created by Krzysztof Pacholak on 05/03/2021.
//

import Foundation

struct FlowerIDModel: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [String:Results]
}

struct Results: Codable {
    let pageid: Int
    let extract: String
    let title: String
    let thumbnail: ThumbStruct
    let pageimage: String
}

struct ThumbStruct: Codable {
    let source: String
    let width: Int
    let height: Int
}
