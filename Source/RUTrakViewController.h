//
//  RUTrakViewController.h
//  Trak
//
//  Created by Raul on 8/12/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kRUTrakViewControllerClosedNotification;

@interface RUTrakViewController : UIViewController

@property (nonatomic, copy) NSString *defaultBordName;
@property (nonatomic, copy) NSString *defaultListName;
@property (nonatomic, copy) NSString *callbackURL;
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;

@end
