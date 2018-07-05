//
//  OpeningScreenViewController.swift
//  Budget
//
//  Created by Adam Moore on 7/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class OpeningScreenViewController: UIViewController {
    
    @IBAction func goToMain(_ sender: UIButton) {
        
        performSegue(withIdentifier: "welcomeToMainSegue", sender: self)
        
    }
    
    @IBOutlet weak var dotGif: UIImageView!
    
   
    // DOT gif
    
    var timer = Timer()
    
    var currentNumber = 1
    
    @objc func runDotGif() {
        
        dotGif.image = UIImage(named: "dots.00\(currentNumber).png")
        
        currentNumber = (currentNumber < 3) ? (currentNumber + 1) : 1
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(OpeningScreenViewController.runDotGif), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
