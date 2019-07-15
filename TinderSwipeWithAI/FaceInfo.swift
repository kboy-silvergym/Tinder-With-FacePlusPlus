//
//  FaceInfo.swift
//  TinderSwipeWithAI
//
//  Created by Kei Fujikawa on 2019/07/15.
//  Copyright © 2019 Kboy. All rights reserved.
//

import Foundation

enum Gender: String {
    case male = "Male"
    case female = "Female"
}

struct FaceInfo {
    let gender: Gender
    let age: Int
    let beauty: Int
}
