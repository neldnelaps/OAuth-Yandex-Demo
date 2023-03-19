//
//  DiskFie.swift
//  OAuthYandexDemo
//
//  Created by Natalia Pashkova on 19.03.2023.
//

import Foundation

struct DiskResponse: Codable {
    let items : [DiskFile]?
}

struct DiskFile: Codable {
    let name : String?
    let preview: String?
    let size: Int64?
}
