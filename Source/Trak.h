//
//  Trak.h
//  Trak
//
//  Created by Raul on 8/15/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kTrelloConsumerKey;
extern NSString * const kTrelloConsumerSecret;
extern NSString * const kTrelloDefaultBordName;
extern NSString * const kTellokDefaultListName;
extern NSString * const kOAuthCallBackURL;
extern NSString * const kDefaultServiceName;

@interface Trak : NSObject <UIAccelerometerDelegate>

+ (Trak *)sharedInstance;
-(void) setupWithDictionary:(NSDictionary *) dic;
-(void) presentTrakViewControllerOnViewController:(UIViewController *) viewController;
- (void)installGestureOnWindow:(UIWindow *)window;
-(void) applicationLaunchOptionsWithURL:(NSURL*)url;
@end
