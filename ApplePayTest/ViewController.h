//
//  ViewController.h
//  ApplePayTest
//
//  Created by MEGHA GULATI on 3/14/16.
//  Copyright © 2016 Megha Gulati. All rights reserved.
//

#import <UIKit/UIKit.h>
@import PassKit;

#import <Stripe/Stripe.h>

@interface ViewController : UIViewController<PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *donationAmount;
@property (weak, nonatomic) IBOutlet UILabel *thankYouMessage;
@property (weak, nonatomic) IBOutlet UIButton *donateAgainButton;
- (IBAction)donateAgainPressed:(id)sender;

@property (weak, nonatomic)  UIButton *payButton;

@end

