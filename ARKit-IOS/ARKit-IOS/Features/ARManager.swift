//
//  ARManager.swift
//  ARKit-IOS
//
//  Created by Ved Pahune on 19/02/24.
//

import Combine

class ARManager {
    static let shared = ARManager()
    private init() { }
    
    var actionStream = PassthroughSubject<ARActions, Never>()
}

