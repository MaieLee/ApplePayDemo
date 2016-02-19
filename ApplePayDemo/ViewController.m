//
//  ViewController.m
//  ApplePayDemo
//
//  Created by mylee on 16/2/19.
//  Copyright © 2016年 mylee. All rights reserved.
//

//证书配置：http://www.cocoachina.com/ios/20150126/11019.html

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    NSLog(@"Payment was authorized: %@", payment);
    
    // do an async call to the server to complete the payment.
    // See PKPayment class reference for object parameters that can be passed
    BOOL asyncSuccessful = FALSE;
    
    // When the async call is done, send the callback.
    // Available cases are:
    //    PKPaymentAuthorizationStatusSuccess, // Merchant auth'd (or expects to auth) the transaction successfully.
    //    PKPaymentAuthorizationStatusFailure, // Merchant failed to auth the transaction.
    //
    //    PKPaymentAuthorizationStatusInvalidBillingPostalAddress,  // Merchant refuses service to this billing address.
    //    PKPaymentAuthorizationStatusInvalidShippingPostalAddress, // Merchant refuses service to this shipping address.
    //    PKPaymentAuthorizationStatusInvalidShippingContact        // Supplied contact information is insufficient.
    
    if(asyncSuccessful) {
        completion(PKPaymentAuthorizationStatusSuccess);
        
        // do something to let the user know the status
        
        NSLog(@"Payment was successful");
        
        //        [Crittercism endTransaction:@"checkout"];
        
    } else {
        completion(PKPaymentAuthorizationStatusFailure);
        
        // do something to let the user know the status
        
        NSLog(@"Payment was unsuccessful");
        
        //        [Crittercism failTransaction:@"checkout"];
    }
    
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    NSLog(@"Finishing payment view controller");
    
    // hide the payment window
    [controller dismissViewControllerAnimated:TRUE completion:nil];
}

- (IBAction)checkOut:(id)sender
{
    // [Crittercism beginTransaction:@"checkout"];
    
    if([PKPaymentAuthorizationViewController canMakePayments]) {
        
        NSLog(@"Can make payments!");
        
        PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
        PKPaymentSummaryItem *widget1 = [PKPaymentSummaryItem summaryItemWithLabel:@"项目 1"
                                                                            amount:[NSDecimalNumber decimalNumberWithString:@"0.01"]];
        
        PKPaymentSummaryItem *widget2 = [PKPaymentSummaryItem summaryItemWithLabel:@"项目 2"
                                                                            amount:[NSDecimalNumber decimalNumberWithString:@"0.01"]];
        
        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"XXX公司"
                                                                          amount:[NSDecimalNumber decimalNumberWithString:@"0.02"]];
        
        request.paymentSummaryItems = @[widget1, widget2, total];
        
        request.countryCode = @"CN";
        request.currencyCode = @"CNY";
        // This is a test merchant id to demo the capability, this would work with Visa cards only.
        request.merchantIdentifier = @"merchant.mylee.ApplePayDemo";  // replace with YOUR_APPLE_MERCHANT_ID
        request.applicationData = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        request.merchantCapabilities = PKMerchantCapability3DS;
        request.supportedNetworks = @[PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkAmex,PKPaymentNetworkChinaUnionPay];
        //        request.requiredBillingAddressFields = PKAddressFieldPostalAddress|PKAddressFieldPhone|PKAddressFieldEmail;
        //        request.requiredShippingAddressFields = PKAddressFieldPostalAddress|PKAddressFieldPhone|PKAddressFieldEmail;
        
        if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:request.supportedNetworks]) {
            PKPaymentAuthorizationViewController *vc = nil;
            
            // need to setup correct entitlement to make the view to show
            @try
            {
                vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
            }
            
            @catch (NSException *e)
            {
                NSLog(@"Exception %@", e);
            }
            
            if (vc != nil)
            {
                vc.delegate = self;
                [self presentViewController:vc animated:YES completion:nil];
            }
            else
            {
                //The device cannot make payments.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PassKit Payment Error"
                                                                message:NSLocalizedString(@"The device cannot make payment at this time. 检查你的merchantid，是否已经绑定银行卡", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    } else {
        //The device cannot make payments. Please make sure Passbook has valid Credit Card added.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PassKit Payment Error"
                                                        message:NSLocalizedString(@"The device cannot make payment at this time. 检查你的merchantid，是否已经绑定银行卡", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
