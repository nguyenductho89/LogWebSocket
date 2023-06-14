//
//  SceneDelegate.swift
//  log
//
//  Created by Tho on 14/06/2023.
//

import UIKit
import Alamofire
let webSocketManager = WebSocketManager()
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        let configuration = URLSessionConfiguration.af.default
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = Session(eventMonitors: [ webSocketManager ])
        UIViewController.swizzleViewWillDisappear()
        webSocketManager.connectToWebSocket()
            // Usage example
            // Send log message
            Array(0...30000).makeIterator().forEach( { index in
                //DispatchQueue.global().sync {
                   // Thread.sleep(forTimeInterval: 1.0)
                    
                    
//                    var info  = ""
//                    let callStackSymbols = Thread.callStackSymbols
//
//                    for (index, symbol) in callStackSymbols.enumerated() {
//                        let components = symbol.components(separatedBy: " ")
//                        let methodName = components[1]
//                        let className = components[2]
//                        let formattedSymbol = "\(index): methodName=\(methodName) in className=\(className)\n"
//                        info.append(formattedSymbol)
//                    }
//
//                    
//                    webSocketManager.sendLogMessage(message: info)
               // }
                
            })
            
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

import Foundation

class WebSocketManager: EventMonitor {
    var webSocketTask: URLSessionWebSocketTask?
    let sendQueue = DispatchQueue(label: "com.yourapp.websocket.sendQueue")

    func connectToWebSocket() {
        let url = URL(string: "ws://192.168.1.3:9999")!
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        receiveMessages()
    }

    func sendLogMessage(message: String) {
        sendQueue.async { [weak self] in
            let message = URLSessionWebSocketTask.Message.string(message)
            self?.webSocketTask?.send(message) { error in
                if let error = error {
                    print("Error sending WebSocket message: \(error)")
                } else {
                    print("Log message sent successfully")
                }
            }
        }
    }

    func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received message from WebSocket server: \(text)")
                case .data(let data):
                    print("Received data from WebSocket server: \(data)")
                }
            case .failure(let error):
                print("Error receiving WebSocket message: \(error)")
            }

            self?.receiveMessages() // Continuously receive messages
        }
    }
    
    func requestDidResume(_ request: Request) {
        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        let message = """
        ⚡️ Request Started: \(request)
        ⚡️ Body Data: \(body)
        """
        self.sendLogMessage(message: message)
    }

    func requestDidFinish(_ request: Request) {
        self.sendLogMessage(message: request.cURLDescription())
    }
}
