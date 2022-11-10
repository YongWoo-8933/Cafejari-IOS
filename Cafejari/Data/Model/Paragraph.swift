//
//  Paragraph.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/28.
//

import Foundation

struct Paragraph {
    let title: String
    let content: String
    var image: String?
    
    init(title: String, content: String, image: String? = nil) {
        self.title = title
        self.content = content
        self.image = image
    }
}

typealias Paragraphs = [Paragraph]
