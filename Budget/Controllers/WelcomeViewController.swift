//
//  WelcomeViewController.swift
//  Budget
//
//  Created by Adam Moore on 7/6/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var welcomeToLabel: UILabel!
    
    @IBOutlet weak var goToMainButton: UIButton!
    
    @IBAction func goToMain(_ sender: UIButton) {
        
        performSegue(withIdentifier: "welcomeToMainSegue", sender: self)
//        UserDefaults.standard.set(false, forKey: "firstTime")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.welcomeToLabel.center = CGPoint(x: self.welcomeToLabel.center.x, y: self.welcomeToLabel.center.y - 50)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            UIView.animate(withDuration: 0.5) {
                
                self.welcomeToLabel.center = CGPoint(x: self.welcomeToLabel.center.x, y: self.welcomeToLabel.center.y + 50)
                self.welcomeToLabel.alpha = 1.0
                
            }
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            UIView.animate(withDuration: 0.5) {
                
                self.goToMainButton.alpha = 1.0
                
            }
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.welcomeToLabel.alpha = 0.0
        self.goToMainButton.alpha = 0.0
        
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
