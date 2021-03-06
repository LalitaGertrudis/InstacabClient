//
//  ICVerifyMobileViewController.h
//  InstaCab
//
//  Created by Pavel Tisunov on 05/04/14.
//  Copyright (c) 2014 Bright Stripe. All rights reserved.
//

@protocol ICVerifyMobileDelegate <NSObject>
-(void)didConfirmMobile;
@end

@interface ICVerifyMobileViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UILabel *mobileNumberLabel;
@property (strong, nonatomic) IBOutlet UITextField *tokenTextField;
@property (strong, nonatomic) IBOutlet UIButton *requestConfirmationButton;
- (IBAction)resendConfirmation:(id)sender;

@property (nonatomic, weak) id<ICVerifyMobileDelegate> delegate;
@end
