//
//  MeterViewController.m
//  PlugMeter
//
//  Created by Mario Cecchi on 5/20/15.
//  Copyright (c) 2015 PlugMeter. All rights reserved.
//

#import "MeterViewController.h"

@interface MeterViewController ()

@property (nonatomic) UIAlertController *alertController;

@end

static const NSString* host = @"192.168.4.1";

@implementation MeterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.correnteLabel.text = @"";
    self.potenciaLabel.text = @"";
    self.gastoEstLabel.text = @"";
    self.gastoTotalLabel.text = @"";
    self.estadoLabel.text = @"";
    self.erroLabel.text = @"";
    
    self.ligarButton.enabled = NO;
    self.desligarButton.enabled = NO;
    
    self.alertController = [UIAlertController alertControllerWithTitle:@"Erro"
                                                               message:@""
                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    [self.alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    

    [self fetchMeterState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchMeterState {
    NSString* requestURL = [NSString stringWithFormat:@"http://%@/", host];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    
    self.erroLabel.text = @"";
    
    [self.activityIndicator startAnimating];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self.activityIndicator stopAnimating];
        
        if (!connectionError) {
            NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Reponse body: %@", responseBody);
            
            NSError* jsonDecodeError;
            NSDictionary* status = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments error:&jsonDecodeError];
            if (jsonDecodeError) {
                self.alertController.message = @"Erro lendo informações do Plug Meter.";
                [self presentViewController:self.alertController animated:YES completion:nil];
            } else {
                
                float corrente = [(NSNumber*)status[@"corrente"] floatValue];
                float potencia = [(NSNumber*)status[@"potencia"] floatValue];
                float custoEstimado = [(NSNumber*)status[@"custo_est_hora"] floatValue];
                float custoTotal = [(NSNumber*)status[@"custo_total"] floatValue];
                
                if ([status[@"rele"] isEqualToString:@"ON"]) {
                    self.estadoLabel.text = @"Ligado";
                    self.ligarButton.enabled = NO;
                    self.desligarButton.enabled = YES;
                } else if ([status[@"rele"] isEqualToString:@"OFF"]) {
                    self.estadoLabel.text = @"Desligado";
                    self.ligarButton.enabled = YES;
                    self.desligarButton.enabled = NO;
                }
                
                self.correnteLabel.text = [NSString stringWithFormat:@"%.2f A", corrente];
                self.potenciaLabel.text = [NSString stringWithFormat:@"%.2f W", potencia];
                self.gastoEstLabel.text = [NSString stringWithFormat:@"R$ %.2f", custoEstimado];
                self.gastoTotalLabel.text = [NSString stringWithFormat:@"R$ %.2f", custoTotal];
                
            }
        } else {
            self.alertController.message = [connectionError localizedDescription];
            [self presentViewController:self.alertController animated:YES completion:nil];
        }
    }];

}

- (void)updateRelayWithStateOn:(BOOL)on {
    NSString* requestURL = [NSString stringWithFormat:@"http://%@/%@", host, on ? @"on" : @"off"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    request.HTTPMethod = @"POST";
    
    self.erroLabel.text = @"";
    
    [self.activityIndicator startAnimating];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self.activityIndicator stopAnimating];
        
        if (!connectionError) {
            NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Reponse body: %@", responseBody);
            
            if ([responseBody isEqualToString:@"ON"]) {
                self.estadoLabel.text = @"Ligado";
                self.ligarButton.enabled = NO;
                self.desligarButton.enabled = YES;
            } else if ([responseBody isEqualToString:@"OFF"]) {
                self.estadoLabel.text = @"Desligado";
                self.ligarButton.enabled = YES;
                self.desligarButton.enabled = NO;
            }
            
        } else {
            self.alertController.message = [connectionError localizedDescription];
            [self presentViewController:self.alertController animated:YES completion:nil];
        }
    }];

}

- (IBAction)atualizarButtonTapped:(id)sender {
    NSLog(@"Clicou atualizar");
    [self fetchMeterState];
}

- (IBAction)ligarButtonTapped:(id)sender {
    self.ligarButton.enabled = NO;
    [self updateRelayWithStateOn:YES];
}

- (IBAction)desligarButtonTapped:(id)sender {
    self.desligarButton.enabled = NO;
    [self updateRelayWithStateOn:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
