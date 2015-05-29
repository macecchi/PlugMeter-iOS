//
//  MeterViewController.h
//  PlugMeter
//
//  Created by Mario Cecchi on 5/20/15.
//  Copyright (c) 2015 PlugMeter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *correnteLabel;
@property (weak, nonatomic) IBOutlet UILabel *potenciaLabel;
@property (weak, nonatomic) IBOutlet UILabel *gastoEstLabel;
@property (weak, nonatomic) IBOutlet UILabel *gastoTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *estadoLabel;
@property (weak, nonatomic) IBOutlet UILabel *erroLabel;
@property (weak, nonatomic) IBOutlet UIButton *ligarButton;
@property (weak, nonatomic) IBOutlet UIButton *desligarButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
