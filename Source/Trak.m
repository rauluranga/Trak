//
//  Trak.m
//  Trak
//
//  Created by Raul on 8/15/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "Trak.h"
#import "RUTrakViewController.h"
#import "RUTrelloHttpClient.h"

NSString * const kTrelloConsumerKey = @"com.trak.kTrackConsumerKey";
NSString * const kTrelloConsumerSecret = @"com.trak.kTrakConsumerSecret";
NSString * const kTrelloDefaultBordName = @"com.trak.kTrakDefaultBordName";
NSString * const kTellokDefaultListName = @"com.trak.kTrakDefaultListName";
NSString * const kOAuthCallBackURL = @"com.trak.kTakCallbackURL";
NSString * const kDefaultServiceName = @"com.trak.kDefaultServiceName";

@interface Trak()

@property(nonatomic) BOOL isOpen;
@property(nonatomic) NSDictionary *userDefaults;
@property(nonatomic) UISwipeGestureRecognizer *swipeGestureRecognizer;

- (void)gestureRecognizerDidFire:(UITapGestureRecognizer *)gestureRecognizer;

@end

@implementation Trak

+ (Trak *)sharedInstance
{
    static dispatch_once_t pred;
    static Trak *_sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(id) init {
    self = [super init];
    if (self != nil) {
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(controllerClosed:)
                                                     name:kRUTrakViewControllerClosedNotification
                                                   object:nil];
    }
    return self;
}

-(void) setupWithDictionary:(NSDictionary *) dic {
    
    assert(dic[kTrelloConsumerKey] != NULL);
    assert(dic[kTrelloConsumerSecret] != NULL);
    assert(dic[kTrelloDefaultBordName] != NULL);
    assert(dic[kTellokDefaultListName] != NULL);
    assert(dic[kOAuthCallBackURL] != NULL);
    assert(dic[kDefaultServiceName] != NULL);
    
    [self setUserDefaults:dic];
        
}

-(void) controllerClosed:(NSNotification *) notification {
    self.isOpen = NO;
}


-(void) applicationLaunchOptionsWithURL:(NSURL *)url {
        
    NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kAFApplicationLaunchOptionsURLKey]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


-(void) presentTrakViewControllerOnViewController:(UIViewController *) viewController {
    [self performSelector:@selector(deleyedPresentTrakViewControllerOnViewController:) withObject:viewController afterDelay:0.125f];
}

-(void) deleyedPresentTrakViewControllerOnViewController:(UIViewController *) viewController  {
    
    if (self.isOpen) {
        return;
    }
    
    self.isOpen = YES;
    
    RUTrakViewController *vc = [[RUTrakViewController alloc] init];
    
    vc.defaultBordName = self.userDefaults[kTrelloDefaultBordName];
    vc.defaultListName = self.userDefaults[kTellokDefaultListName];
    vc.callbackURL = self.userDefaults[kOAuthCallBackURL];
    vc.serviceName = self.userDefaults[kDefaultServiceName];
    vc.consumerKey = self.userDefaults[kTrelloConsumerKey];
    vc.consumerSecret = self.userDefaults[kTrelloConsumerSecret];
        
    [viewController presentViewController:vc animated:NO completion:nil];
}

- (void)installGestureOnWindow:(UIWindow *)window {
    
    if (self.swipeGestureRecognizer) return;
    
    self.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerDidFire:)];
    [self.swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.swipeGestureRecognizer setNumberOfTouchesRequired:3];
    [self.swipeGestureRecognizer setDelaysTouchesBegan:YES];
    [window addGestureRecognizer:self.swipeGestureRecognizer];
    
    
    
}

- (void)gestureRecognizerDidFire:(UISwipeGestureRecognizer *)gestureRecognizer {
   
    NSUInteger touches = gestureRecognizer.numberOfTouches;
        
    switch (touches) {
        case 1:
            break;
        case 2:
            break;
        case 3:
            [self presentTrakViewControllerOnViewController:topMostController()];
            break;
        default:
            break;
    }
}

//Shake
//http://stackoverflow.com/questions/3416536/how-to-detect-shake-on-the-iphone-using-cocos2d
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    const float THRESHOLD = 1.7f;
    static BOOL shake_once;
        
    if (acceleration.x > THRESHOLD || acceleration.x < -THRESHOLD ||
        acceleration.y > THRESHOLD || acceleration.y < -THRESHOLD ||
        acceleration.z > THRESHOLD || acceleration.z < -THRESHOLD) {
        
        if (!shake_once) {
            shake_once = true;
            [self presentTrakViewControllerOnViewController:topMostController()];
        }
        
    }
    else {
        shake_once = false;
    }
}

/*
https://github.com/usepropeller/IssueKit/blob/master/IssueKit/IssueKit/ISKIssueManager.m#L106
 */

UIViewController *_topMostController(UIViewController *cont) {
    UIViewController *topController = cont;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if ([topController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)topController).visibleViewController;
        if (visible) {
            topController = visible;
        }
    }
    
    return (topController != cont ? topController : nil);
}

UIViewController *topMostController() {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *next = nil;
    
    while ((next = _topMostController(topController)) != nil) {
        topController = next;
    }
    
    return topController;
}

@end
