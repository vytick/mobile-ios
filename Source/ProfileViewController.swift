//
//  ProfileViewController.swift
//  Rekola
//
//  Created by Daniel Brezina on 01/07/15.
//  Copyright (c) 2015 Ackee s.r.o. All rights reserved.
//

import Foundation
import SnapKit

class ProfileViewController: UIViewController {
    override func loadView() {
        let view = UIView()
        self.view = view
        
        let nameLabel = UILabel()
        view.addSubview(nameLabel)
        nameLabel.snp_makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(view).offset(100)
            }
        self.nameLabel = nameLabel
        
        let dateLabel = UILabel()
        view.addSubview(dateLabel)
        dateLabel.snp_makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(nameLabel.snp_bottom).offset(L.verticalSpacing)
        }
        self.dateLabel = dateLabel
        
        let logoutButton = TintingButton(titleAndImageTintedWith: .rekolaGreenColor(), activeTintColor: UIColor.whiteColor())
        view.addSubview(logoutButton)
        logoutButton.snp_makeConstraints { make in
            make.width.equalTo(169)
            make.height.equalTo(44)
            make.top.equalTo(dateLabel.snp_bottom).offset(L.verticalSpacing)
//                    make.left.right.equalTo(view)
            make.centerX.equalTo(view.snp_centerX)
        }
        self.logoutButton = logoutButton
        
        let staticEmailLabel = UILabel()
        staticEmailLabel.text = NSLocalizedString("PROFILE_email", comment: "")
        staticEmailLabel.textColor = .staticGrayTextColor()
        staticEmailLabel.textAlignment = .Left
        view.addSubview(staticEmailLabel)
        staticEmailLabel.snp_makeConstraints { make in
            make.left.equalTo(view).offset(L.horizontalSpacing)
            make.top.equalTo(logoutButton.snp_bottom).offset(L.verticalSpacing)
        }
        
        let emailLabel = UILabel()
        view.addSubview(emailLabel)
        emailLabel.snp_makeConstraints { make in
            make.left.greaterThanOrEqualTo(staticEmailLabel.snp_right).offset(L.horizontalSpacing)
            make.right.equalTo(view).offset(-L.horizontalSpacing).priorityLow()
            make.top.equalTo(logoutButton.snp_bottom).offset(L.verticalSpacing)
        }
        self.emailLabel = emailLabel
        
        let line1 = Theme.lineView()
        view.addSubview(line1)
        line1.snp_makeConstraints { make in
            make.top.equalTo(emailLabel.snp_bottom).offset(L.verticalSpacing)
            make.left.equalTo(view).offset(L.horizontalSpacing)
            make.right.equalTo(view).offset(-L.horizontalSpacing)
            make.height.equalTo(1)
//            make.width.equalTo(300)
        }
        
        let staticAddressLabel = UILabel()
        staticAddressLabel.text = NSLocalizedString("PROFILE_address", comment: "")
        staticAddressLabel.textColor = .staticGrayTextColor()
        staticAddressLabel.textAlignment = .Left
        view.addSubview(staticAddressLabel)
        staticAddressLabel.snp_makeConstraints { make in
            make.left.equalTo(view).offset(L.horizontalSpacing)
            make.top.equalTo(line1.snp_bottom).offset(L.verticalSpacing)
        }
        
        let addressLabel = UILabel()
        view.addSubview(addressLabel)
        addressLabel.snp_makeConstraints { make in
            make.right.equalTo(view).offset(-L.horizontalSpacing).priorityLow()
            make.left.greaterThanOrEqualTo(staticAddressLabel.snp_right).offset(L.horizontalSpacing)
            make.top.equalTo(line1.snp_bottom).offset(L.verticalSpacing)
        }
        self.addressLabel = addressLabel
        
        let line2 = Theme.lineView()
        view.addSubview(line2)
        line2.snp_makeConstraints { make in
            make.top.equalTo(staticAddressLabel.snp_bottom).offset(L.verticalSpacing)
            make.left.equalTo(view).offset(L.horizontalSpacing)
            make.right.equalTo(view).offset(-L.horizontalSpacing)
            make.height.equalTo(1)
//            make.width.equalTo(300)
        }
        
        let staticPhoneLabel = UILabel()
        staticPhoneLabel.text = NSLocalizedString("PROFILE_phone", comment: "")
        staticPhoneLabel.textColor = .staticGrayTextColor()
        staticPhoneLabel.textAlignment = .Left
        view.addSubview(staticPhoneLabel)
        staticPhoneLabel.snp_makeConstraints { make in
            make.left.equalTo(view).offset(L.horizontalSpacing)
            make.top.equalTo(line2.snp_bottom).offset(L.verticalSpacing)
        }
        
        let phoneLabel = UILabel()
        view.addSubview(phoneLabel)
        phoneLabel.snp_makeConstraints { make in
            make.left.greaterThanOrEqualTo(staticPhoneLabel.snp_right).offset(L.horizontalSpacing)
            make.right.equalTo(view).offset(-L.horizontalSpacing).priorityLow()
            make.top.equalTo(line2.snp_bottom).offset(L.verticalSpacing)
        }
        self.phoneLabel = phoneLabel
        
        let aboutAppButton = Theme.grayButton()
        view.addSubview(aboutAppButton)
        aboutAppButton.snp_makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalTo(view).offset(L.horizontalSpacing)
            make.right.equalTo(view).offset(-L.horizontalSpacing)
            make.bottom.equalTo(view).offset(-50)
        }
        self.aboutAppButton = aboutAppButton
        
    }
    
    weak var nameLabel: UILabel!
    weak var dateLabel: UILabel!
    weak var logoutButton: TintingButton!
    weak var emailLabel: UILabel!
    weak var addressLabel: UILabel!
    weak var phoneLabel: UILabel!
    weak var aboutAppButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = .whiteColor()
        
//        following text will be replace with text from API
        self.nameLabel.text = "Korben Dallas"
        self.nameLabel.font = UIFont.boldSystemFontOfSize(26)
        self.nameLabel.textAlignment = .Center

        self.dateLabel.text = dateLabelFormat("21.08.2015")
        self.dateLabel.textColor = .rekolaPinkColor()
        self.dateLabel.textAlignment = .Center

        self.logoutButton.setTitle("  Odhlásit se", forState: .Normal)
        self.logoutButton.setTitle(NSLocalizedString("PROFILE_logout", comment: ""), forState: .Normal)
        self.logoutButton.setImage(UIImage(imageIdentifier: .logoutButton), forState: .Normal)
        self.logoutButton.layer.borderColor = UIColor.rekolaGreenColor().CGColor
        self.logoutButton.layer.borderWidth = 1
        self.logoutButton.layer.cornerRadius = 4
        
        self.emailLabel.text = "korben.dallas@multipass.com"
        self.emailLabel.textAlignment = .Right

        self.addressLabel.text = "Bechynova 274/8, Praha 6"
        self.addressLabel.textAlignment = .Left
        
        self.phoneLabel.text = "+420 555 555 555"
        self.phoneLabel.textAlignment = .Right
        
        self.aboutAppButton.setTitle(NSLocalizedString("PROFILE_about", comment: ""), forState: .Normal)
        self.aboutAppButton.addTarget(self, action: "aboutAppPressed", forControlEvents: .TouchUpInside)
    }
    
    func aboutAppPressed() {
        let aboutAppVC = AboutAppViewController()
        
        self.showViewController(aboutAppVC, sender: nil)
    }
    
    func dateLabelFormat(date: String) -> String! {
        let str = NSLocalizedString("PROFILE_membership", comment: "") + date
        return str
    }
    
    
}
