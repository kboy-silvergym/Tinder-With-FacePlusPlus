//
//  SoundUseCase.swift
//  TinderSwipeWithAI
//
//  Created by Kei Fujikawa on 2019/07/15.
//  Copyright © 2019 Kboy. All rights reserved.
//

import Foundation

import Foundation
import AVFoundation
import UIKit

enum Sound: String {
    case correct1
    case incorrect1
    case heart1
}

class SoundUseCase {
    static var sePlayer: AVAudioPlayer?
    
    static func playSound(type: Sound) {
        guard let sound = NSDataAsset(name: type.rawValue) else { return }
        sePlayer = try? AVAudioPlayer(data: sound.data)
        
        if type == .heart1 {
            sePlayer?.numberOfLoops = 5
        } else {
            sePlayer?.numberOfLoops = 0
        }
        sePlayer?.play()
    }
    
    static func stopMusic() {
        sePlayer?.stop()
    }
}

