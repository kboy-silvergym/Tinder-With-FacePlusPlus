//
//  ViewController.swift
//  TinderSwipeWithAI
//
//  Created by Kei Fujikawa on 2019/07/15.
//  Copyright © 2019 Kboy. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var faceScoreLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private let api = FacePlusAPI()
    
    private var webView: WKWebView!
    
    private let javascriptCode = """
function like() {
        const elem = document.getElementsByClassName("recsGamepad__button");
        elem[3].click();
};

function unLike() {
        const elem = document.getElementsByClassName("recsGamepad__button");
        elem[1].click();
};
"""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: webViewContainer.bounds, configuration: webConfiguration)
        webViewContainer.addSubview(webView)
        
        let myURL = URL(string:"https://tinder.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        webView.evaluateJavaScript(
            self.javascriptCode,
            completionHandler: { result, error in
                
        })
    }
    
    private func processFace(completionHandler: (() -> Void)?){
        SoundUseCase.playSound(type: .heart1)
        
        self.genderLabel.text = ""
        self.ageLabel.text = "判定中....."
        self.faceScoreLabel.text = ""
        
        indicator.isHidden = false
        indicator.startAnimating()
        
        let image: UIImage = self.webViewContainer.screenShot()
        self.api.processFace(image: image, handler: { faceInfo in
            SoundUseCase.stopMusic()
            
            guard let faceInfo = faceInfo else {
                self.indicator.stopAnimating()
                self.ageLabel.text = "測定不能"
                self.unLike()
                return
            }
            self.genderLabel.text = "性別: " + faceInfo.gender.rawValue
            self.ageLabel.text = "年齢: " + faceInfo.age.description
            self.faceScoreLabel.text = "顔面スコア: " + faceInfo.beauty.description
            
            let isFemale: Bool = faceInfo.gender == .female
            let isUnder30: Bool = faceInfo.age < 30
            let isKawaii: Bool = faceInfo.beauty > 50
            
            if isFemale, isUnder30, isKawaii {
                self.faceScoreLabel.textColor = .red
                self.indicator.stopAnimating()
                self.like()
            } else {
                self.faceScoreLabel.textColor = .blue
                self.indicator.stopAnimating()
                self.unLike()
            }
        })
    }
    
    private func like(){
        SoundUseCase.playSound(type: .correct1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.webView.evaluateJavaScript(
                "like();",
                completionHandler: { result, error in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.processFace(){ }
                    }
            })
        }
    }
    
    private func unLike(){
        SoundUseCase.playSound(type: .incorrect1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.webView.evaluateJavaScript(
                "unLike();",
                completionHandler: { result, error in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.processFace(){ }
                    }
            })
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        processFace() {
            
        }
    }
}

extension UIView {
    func screenShot() -> UIImage {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
}
