//
//  Start_view_controller.swift
//  SceneDepthPointCloud
//
//  Created by Monali Palhal on 18/08/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit

class Start_view_controller: UIViewController {

    @IBOutlet weak var startscan: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func StartScan(_ sender: Any) {
        print("button click")
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = mainStoryBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
