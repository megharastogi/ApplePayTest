//
//  ViewController.m
//  ApplePayTest
//
//  Created by MEGHA GULATI on 3/14/16.
//  Copyright © 2016 Megha Gulati. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Conditionally show Apple Pay button based on device availability
    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]]) {
        _payButton = [self applePayButton];
        
        //Set location of Apple Pay button
        _payButton.frame = CGRectMake(_donationAmount.frame.origin.x, _donationAmount.frame.origin.y + _donationAmount.frame.size.height + 22.0, _payButton.frame.size.width, _payButton.frame.size.height);

        [self.view addSubview:_payButton];
    }else{
        //Create alternate payment flow
    }
}

- (UIButton *)applePayButton {
    UIButton *button;
    
    if ([PKPaymentButton class]) { // Available in iOS 8.3+
        button = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
    } else {
        // Create and return your own apple pay button
    }
    
    [button addTarget:self action:@selector(tappedApplePay) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)tappedApplePay{
    if ([self checkFormValid]){
        PKPaymentRequest *paymentRequest = [self paymentRequest:_donationAmount.text];
        PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Please fill in all details" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        
         [alert addAction:ok];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(BOOL)checkFormValid{
    BOOL valid = false;
    
    if ([_userName.text isEqualToString:@""] || [_userEmail.text isEqualToString:@""]|| [_donationAmount.text isEqualToString:@""]) {
        valid = false;
    }else{
        valid = true;
    }
    return valid;
}

- (PKPaymentRequest *)paymentRequest:(NSString *)amount {
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantIdentifier = @"merchant.com.xxxxxx";
    paymentRequest.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.countryCode = @"US";
    paymentRequest.currencyCode = @"USD";
    paymentRequest.paymentSummaryItems =
    @[
      [PKPaymentSummaryItem summaryItemWithLabel:@"Donation" amount:[NSDecimalNumber decimalNumberWithString:amount]],
      ];
    return paymentRequest;
}



- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
    
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    
    _donationAmount.text = @"";
    _userEmail.text = @"";
    _userName.text = @"";
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken *token, NSError *error) {
         if (error) {
             completion(PKPaymentAuthorizationStatusFailure);
             return;
         }
         [self createBackendChargeWithToken:token completion:completion];
    }];
}

- (void)createBackendChargeWithToken:(STPToken *)token completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    //We are printing Stripe token here, you can charge the Credit Card using this token from your backend.
    NSLog(@"Stripe Token is %@",token);
    completion(PKPaymentAuthorizationStatusSuccess);
    //Displaying user Thank you message for payment.
    _thankYouMessage.hidden = false;
    _payButton.hidden = true;
    _donateAgainButton.hidden =false;
}



- (IBAction)donateAgainPressed:(id)sender {
    _payButton.hidden =false;
    _donateAgainButton.hidden= true;
    _thankYouMessage.hidden = true;
}
@end
