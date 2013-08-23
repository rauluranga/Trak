//
//  GWViewController.m
//  Trak
//
//  Created by Raul on 8/5/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "MasterViewController.h"
#import "Trak.h"

@interface MasterViewController ()

@end

@implementation MasterViewController


-(UIColor *) randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[self randomColor]];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(NSInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)show:(UIButton *)sender {
    [[Trak sharedInstance] presentTrakViewControllerOnViewController:self];
}

@end
