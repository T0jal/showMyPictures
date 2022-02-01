//
//  Image.swift
//  showMyPictures
//
//  Created by António Rocha on 03/12/2021.
//

import UIKit

class Picture: NSObject, Codable {
    var filename: String
    var caption: String
    var filePath: URL

    init(filename: String, caption: String, filePath: URL) {
        self.filename = filename
        self.caption = caption
        self.filePath = filePath
    }
}
