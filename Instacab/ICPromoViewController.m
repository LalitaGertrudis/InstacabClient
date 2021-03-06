//
//  ICPromoViewController.m
//  InstaCab
//
//  Created by Pavel Tisunov on 22/04/14.
//  Copyright (c) 2014 Bright Stripe. All rights reserved.
//

#import "ICPromoViewController.h"
#import "ICClientService.h"
#import "MBProgressHud+Global.h"
#import "RESideMenu.h"
#import "AnalyticsManager.h"

@implementation ICTextField

-(CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 30, -10);
}

-(CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 30, -10);
}

@end

@interface ICPromoViewController ()

@end

@implementation ICPromoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleText = @"ПРОМО-ПРЕДЛОЖЕНИЕ";
    
    self.view.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    
    _borderView.layer.borderColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1].CGColor;
    _borderView.layer.borderWidth = 1.0;
    _borderView.layer.cornerRadius = 3.0;
    
    _promoCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    _promoCodeTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"promo_icon"]];
    _promoCodeTextField.delegate = self;

    BOOL standalone = [self.navigationController.parentViewController isKindOfClass:RESideMenu.class];
    
    if (standalone) {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"sidebar_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]  style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
        
        self.navigationItem.leftBarButtonItem = barButton;
    }
    else {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
        
        self.navigationItem.rightBarButtonItem = barButton;
    }
    
    [AnalyticsManager track:@"PromoPageView" withProperties:nil];
}

-(void)showMenu {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)applyPromo {
    MBProgressHUD *hud = [MBProgressHUD showGlobalProgressHUDWithTitle:@"Загрузка"];
    
    NSString *promoCode = _promoCodeTextField.text;
    
    [AnalyticsManager track:@"ApplyPromoRequest" withProperties:@{ @"promoCode": promoCode }];
    
    [[ICClientService sharedInstance] applyPromo:promoCode success:^(ICPing *message) {
        ICApiResponse *response = message.apiResponse;
        if (!response) return;
        
        NSDictionary *data = message.apiResponse.data;
        if (data) {
            NSString *error = data[@"error"];
            if (error) {
                _messageLabel.text = error;
                
                // Error
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fail_icon.png"]];
                hud.mode = MBProgressHUDModeCustomView;
                hud.labelText = @"Ошибка";
                [hud hide:YES afterDelay:2];
            }
            else {
                _promoCodeTextField.text = @"";
                _messageLabel.text = data[@"description"];
                
                // Success
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success_icon.png"]];
                hud.mode = MBProgressHUDModeCustomView;
                hud.labelText = @"Готово!";
                [hud hide:YES afterDelay:2];
                
                [AnalyticsManager increment:@"promo codes activated"];
            }
        }
        
        [AnalyticsManager track:@"ApplyPromoResponse" withProperties:@{ @"statusCode": message.apiResponse.error.statusCode }];
    } failure:^{
        _messageLabel.text = @"Произошел сбой сетевого соединения";
        [MBProgressHUD hideGlobalHUD];
    }];
}

- (void)back
{
    [MBProgressHUD hideGlobalHUD];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)promoChanged:(id)sender {
    if ([_promoCodeTextField.text length] != 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self applyPromo];
    return YES;
}

@end
