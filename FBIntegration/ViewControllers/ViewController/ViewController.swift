//
//  ViewController.swift
//  FBIntegration
//
//  Created by Chandra Rao on 24/03/18.
//  Copyright © 2018 Chandra Rao. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    
    @IBOutlet weak var imgProfilePicture: UIImageView!
    @IBOutlet weak var lblUserId: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblEmailAddress: UILabel!
    @IBOutlet weak var btnFbLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnFBLoginClicked(_ sender: Any) {
        let loginManager : FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile","email"], from: self) { (result, error) in
            if error == nil {
                let strToken : String = (result?.token.tokenString)!
                print("Easy Solutions Web's FB Token = \(strToken)")
                DispatchQueue.main.async {
                    self.btnFbLogin.titleLabel?.text = "Logout User"
                    self.getFacebookProfileInfo()
                }
            }
        }
    }
    
    func getFacebookProfileInfo() {
        
        let requestMe : FBSDKGraphRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields" : "id,name,email,picture.width(100).height(100)"])
        let connection : FBSDKGraphRequestConnection = FBSDKGraphRequestConnection()
        
        connection.add(requestMe, completionHandler: { (connectn, userresult, error) in
            
            if let dictData: [String : Any] = userresult as? [String : Any] {
                
                DispatchQueue.main.async {
                    self.lblUserId.text = dictData["id"] as? String
                    self.lblUserName.text = dictData["name"] as? String
                    self.lblEmailAddress.text = dictData["email"] as? String
                    
                    
                    if let pictureData: [String : Any] = dictData["picture"] as? [String : Any] {
                        if let data : [String: Any] = pictureData["data"] as? [String: Any] {
                            print(data)
                            self.fetchImage(url: data["url"] as? String)
                        }
                    }
                }
                
                print(dictData["picture"] ?? "picturevalue")
            }
        }, batchEntryName: "me")
        connection.start()
    }

    private func fetchImage(url : String?) {
        let imageURL = URL(string: url!)
        var image: UIImage?
        if let url = imageURL {
            //All network operations has to run on different thread(not on main thread).
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = NSData(contentsOf: url)
                //All UI operations has to run on main thread.
                DispatchQueue.main.async {
                    if imageData != nil {
                        image = UIImage(data: imageData! as Data)
                        self.imgProfilePicture.image = image
                        self.imgProfilePicture.sizeToFit()
                    } else {
                        image = nil
                    }
                }
            }
        }
    }
    
}

