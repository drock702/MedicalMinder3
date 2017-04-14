//
//  ViewController.swift
//  NaviTests
//
//  Created by Derrick Price on 5/13/15.
//  Copyright (c) 2015 Derrick Price. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack (){
        if let navigationController = self.navigationController
        {
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    deinit
    {
        print("MYOAViewController deinitialized!")
    }
}
