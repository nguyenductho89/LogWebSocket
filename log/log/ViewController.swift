//
//  ViewController.swift
//  log
//
//  Created by Tho on 14/06/2023.
//

import UIKit
import Alamofire
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        AF.request("https://google.com").response { response in
            webSocketManager.sendLogMessage(message: response.description)
        }

        
        webSocketManager.sendLogMessage(message: BSBacktraceLogger.bs_backtraceOfAllThread())
                                        }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }


}

class MyVC: ViewController {}

