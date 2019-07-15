//
//  FacePlusAPI.swift
//  TinderSwipeWithAI
//
//  Created by Kei Fujikawa on 2019/07/15.
//  Copyright © 2019 Kboy. All rights reserved.
//

import Alamofire

class FacePlusAPI {
    let apiKey = ""
    let apiSec = ""
    
    enum URL: String {
        case detect = "https://api-us.faceplusplus.com/facepp/v3/detect"
    }
    
    func processFace(image: UIImage, handler: @escaping (FaceInfo?) -> ()) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            handler(nil)
            return
        }
        let base64Data = imageData.base64EncodedString(options: .lineLength64Characters)
        let parameters: Parameters = [
            "api_key": apiKey,
            "api_secret": apiSec,
            "image_base64": base64Data,
            "return_attributes": "gender,age,smiling,glass,emotion,beauty,ethnicity,skinstatus"
        ]
        AF.request(URL.detect.rawValue, method: .post, parameters: parameters)
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    print(json)
                    guard let json = json as? [String: Any] else {
                        handler(nil)
                        return
                    }
                    print(json)
                    guard let faces = json["faces"] as? [[String: Any]],
                        !faces.isEmpty else {
                            handler(nil)
                            return
                    }
                    
                    let face = faces.first!
                    let attributes = face["attributes"] as! [String: Any]
                    
                    let gender = attributes["gender"] as! [String: String]
                    let age = attributes["age"] as! [String: Int]
                    let beauty = (attributes["beauty"] as! [String: Any])["male_score"] as! NSNumber
                    
                    let info = FaceInfo(
                        gender: Gender(rawValue: gender["value"]!)!,
                        age: age["value"]!,
                        beauty: beauty.intValue
                    )
                    handler(info)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    handler(nil)
                }
        }
        
    }
}
