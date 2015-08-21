//
//  BorrowBikeViewController.swift
//  Rekola
//
//  Created by Daniel Brezina on 08/07/15.
//  Copyright (c) 2015 Ackee s.r.o. All rights reserved.
//

import UIKit
import SnapKit
import Foundation
import ReactiveCocoa

class BorrowedBikeViewController: UIViewController {
	let bike : Bike
	init(bike: Bike) {
		self.bike = bike
		super.init(nibName: nil, bundle: nil)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
        let view = UIView()
        view.backgroundColor = .whiteColor()
        self.view = view
        
        let iv = UIImageView()
		iv.contentMode = .ScaleAspectFit
        view.addSubview(iv)
        iv.snp_makeConstraints { make in
            make.top.equalTo(view).offset(52)
            make.right.left.equalTo(view)
            make.height.equalTo(60)//multipliedBy(0.2)
        }
        self.bikeImageView = iv

        let nameLabel = UILabel()
        view.addSubview(nameLabel)
        nameLabel.font = UIFont(name: Theme.SFFont.Medium.rawValue, size: 30)
        nameLabel.textColor = .rekolaBlackColor()
        nameLabel.textAlignment = .Center
        nameLabel.numberOfLines = 0
        nameLabel.snp_makeConstraints { make in
            make.top.equalTo(iv.snp_bottom).offset(L.verticalSpacing)
            make.left.right.equalTo(view)
        }
        self.bikeNameLabel = nameLabel
        
        let borrowLabel = UILabel()
        view.addSubview(borrowLabel)
        borrowLabel.font = UIFont(name: Theme.SFFont.Medium.rawValue, size: 14)
        borrowLabel.textAlignment = .Center
        borrowLabel.textColor = .rekolaSubtitleBlackColor()
        borrowLabel.snp_makeConstraints { make in
            make.top.equalTo(nameLabel.snp_bottom).offset(5)
            make.left.right.equalTo(view)
        }
        self.bikeBorrowLabel = borrowLabel
        
        let detailButton = TintingButton(titleAndImageTintedWith: .rekolaGreenColor(), activeTintColor: UIColor.whiteColor())
        view.addSubview(detailButton)
        detailButton.layer.borderColor = UIColor.rekolaGreenColor().CGColor
        detailButton.layer.cornerRadius = 4
        detailButton.layer.borderWidth = 2
        detailButton.titleLabel?.font = UIFont(name: Theme.SFFont.Regular.rawValue, size: 17)
        detailButton.snp_makeConstraints { make in
            make.top.equalTo(borrowLabel.snp_bottom).offset(20)
            make.width.equalTo(119)
            make.height.equalTo(45)
            make.centerX.equalTo(view.snp_centerX)
        }
        self.bikeDetailButton = detailButton
        
        let rectangle = UIView()
        rectangle.layer.borderWidth = 2
        rectangle.layer.borderColor = UIColor.rekolaGrayBorderColor().CGColor
        rectangle.layer.cornerRadius = 7
        view.addSubview(rectangle)
        rectangle.snp_makeConstraints { make in
            make.top.equalTo(detailButton.snp_bottom).offset(10)//.multipliedBy(1.1)
            make.height.equalTo(101).multipliedBy(0.1)
//            make.left.right.equalTo(view).inset(L.contentInsets) //changed
            make.centerX.equalTo(view.snp_centerX)
            make.left.equalTo(35)
            make.right.equalTo(-35)
        }
        
        let lockCodeLabel = InsetLabel()
        lockCodeLabel.textColor = .rekolaGrayBorderColor()
        lockCodeLabel.text = NSLocalizedString("BORROWBIKE_code", comment: "")
        lockCodeLabel.inset.left = 5
        lockCodeLabel.inset.right = 5
        lockCodeLabel.font = UIFont(name: Theme.SFFont.Regular.rawValue, size: 15)
        lockCodeLabel.textAlignment = .Center
        lockCodeLabel.backgroundColor = .whiteColor()
        view.addSubview(lockCodeLabel)
        lockCodeLabel.snp_makeConstraints { make in
            make.centerX.equalTo(view.snp_centerX)
            make.centerY.equalTo(rectangle.snp_top)
        }
        
        let codeLabel = UILabel()
        view.addSubview(codeLabel)
        codeLabel.font = UIFont(name: Theme.SFFont.Bold.rawValue, size: 67)
        codeLabel.textAlignment = .Center
        codeLabel.snp_makeConstraints { make in
            make.top.equalTo(rectangle.snp_top).offset(5)
            make.left.equalTo(rectangle.snp_left)
            make.right.equalTo(rectangle.snp_right)
            make.bottom.equalTo(rectangle.snp_bottom)
        }
        self.bikeCodeLabel = codeLabel
        
        let returnButton = Theme.pinkButton()
        view.addSubview(returnButton)
        returnButton.titleLabel?.font = UIFont(name: Theme.SFFont.Regular.rawValue, size: 17)
        returnButton.snp_makeConstraints { make in
            make.bottom.equalTo(view).offset(-L.verticalSpacing)
            make.left.equalTo(view).offset(L.horizontalSpacing)
            make.right.equalTo(view).offset(-L.horizontalSpacing)
            make.height.equalTo(45)
        }
        self.bikeReturnButton = returnButton
    }
    
    weak var bikeImageView: UIImageView!
    weak var bikeNameLabel: UILabel!
    weak var bikeBorrowLabel: UILabel!
    weak var bikeDetailButton: TintingButton!
    weak var bikeCodeImage: UIImageView!
    weak var bikeCodeLabel: UILabel!
    weak var bikeReturnButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        bikeNameLabel.text = bike.name
        
        bikeBorrowLabel.attributedText = formatDateLabel(bike.returnedAt!)
        
        bikeDetailButton.setTitle(NSLocalizedString("BORROWBIKE_detail", comment: ""), forState: .Normal)
        bikeDetailButton.addTarget(self, action: "bikeDetail:", forControlEvents: .TouchUpInside)
        
        let atribute = NSAttributedString(string: bike.lockCode!, attributes: [NSKernAttributeName: (7)])
        
        bikeCodeLabel.attributedText = atribute
        
        bikeReturnButton.setTitle(NSLocalizedString("BORROWBIKE_return", comment: ""), forState: .Normal)
        bikeReturnButton.addTarget(self, action: "returnBike:", forControlEvents: .TouchUpInside)
		
		bikeImageView.sd_setImageWithURL(bike.imageURL)
        
//        showIssue()
    }
    
    func formatDateLabel(date: NSDate) -> NSAttributedString! {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        let dateString = dateFormatter.stringFromDate(date)
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.stringFromDate(date)
        
        let text = NSLocalizedString("BORROWBIKE_lent", comment: "") + dateString + " / " + timeString

        let atribute = NSMutableAttributedString(string: text)
        atribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.rekolaPinkColor(), range: NSRange(location: 8, length: 6))
        atribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.rekolaPinkColor(), range: NSRange(location: 15, length: 6))
        
        println("Text: \(atribute.string) \n pocet: \(atribute.length)")
        
        return atribute
    }
    
////    tmp
//    let issueRequestPending = MutableProperty(false)
//    func showIssue() {
////        issueRequestPending.value = false
//        API.myBikeIssue(id: bike.id).start(error: { error in
////            self.issueRequestPending.value = false
//            self.handleError(error)
//    
////            NSString(data: error.userInfo![APIErrorKeys.responseData]! as! NSData, encoding:4)
//            }, completed: {
//                self.issueRequestPending.value = false
//            },next: {bikeIssue in
////                println("issue: \n \(bikeIssue)()()")
//        })
//    }
    
	func returnBike(sender: AnyObject?) {
		let vc = ReturnBikeViewController(bike: bike)
        showViewController(vc, sender: sender)
    }
    
	func bikeDetail(sender: AnyObject?) {
		let vc = BikeDetailViewController(bike: bike)
        showViewController(vc, sender: sender)
    }
}
