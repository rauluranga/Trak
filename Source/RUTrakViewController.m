//
//  RUTrakViewController.m
//  Trak
//
//  Created by Raul on 8/12/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "RUTrakViewController.h"
#import "UIView+MLScreenshot.h"
#import "RUCanvasView.h"
#import "RNBlurModalView.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "RUTrelloHttpClient.h"

NSString * const kTrelloBaseURL = @"https://trello.com/";

NSString * const kRUTrakViewControllerClosedNotification = @"kRUTrakViewControllerClosedNotification";


@interface UIAlertView (UIAlertView_RUTrakAdditions)
+(UIAlertView*) showWithError:(NSError*) networkError;
@end

@interface UIButton (UIButton_RUTrakAdditions)
+(UIButton *) buttonFromImageNamed:(NSString *)name;
@end

@interface RUCustomNavigationBar : UINavigationBar

@end

@interface RUCustomToolBar : UIToolbar

@end

@interface RULabelsView : UIView
@property (nonatomic) NSArray *buttons;
@end

@interface RUTextContainerView : UIView
+(id) containerViewWithTextView:(UIView *)textView;
@end

@interface RUTrakViewController ()

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UIToolbar *bottomBar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) RULabelsView *labelsView;
@property (nonatomic, strong) RNBlurModalView *modal;
@property (nonatomic, strong) RUCanvasView *canvas;
@property (nonatomic, strong) RUBoardModel *defaultBoard;
@property (nonatomic, strong) RUListModel *defaultList;
@property (nonatomic, strong) NSString *feedback;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, readonly) BOOL isUserAuthorized;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic) BOOL cardRequest;
@property (nonatomic, strong) RUTrelloHttpClient *client;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation RUTrakViewController

-(UINavigationBar *) navigationBar {
    if (!_navigationBar) {
        _navigationBar = [[RUCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];;
    }
    return _navigationBar;
}

-(UIToolbar *) bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[RUCustomToolBar alloc] initWithFrame:CGRectMake(0, 504, 320, 44)];;
    }
    return _bottomBar;
}

-(UIView *) containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    }
    return _containerView;
}

-(UIScrollView *) scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 548)];
    }
    return _scrollView;
}

-(RUCanvasView *) canvas {
    if (!_canvas) {
        _canvas = [[RUCanvasView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
        [_canvas setUserInteractionEnabled:NO];
        
        [_canvas setBrushColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
        [_canvas setBrushSize:5.f];
    }
    return _canvas;
}

-(RULabelsView *) labelsView {
    if (!_labelsView) {
        _labelsView = [[RULabelsView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320, 50)];
    }
    return _labelsView;
}

-(MBProgressHUD *) HUD {
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    }
    return _HUD;
}

-(BOOL) isUserAuthorized {
    return [self.client authorizeFromKeychainForName:self.serviceName];
}

-(UIButton *) cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonFromImageNamed:@"Trak.bundle/close.png"];
        [_cancelButton addTarget:self action:@selector(handleCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(UIButton *) loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonFromImageNamed:@"Trak.bundle/login.png"];
        [_loginButton setImage:[UIImage imageNamed:@"Trak.bundle/login_selected.png"] forState:UIControlStateHighlighted];
        [_loginButton setImage:[UIImage imageNamed:@"Trak.bundle/login_selected.png"] forState:UIControlStateSelected];
        [_loginButton addTarget:self action:@selector(handleLogin:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

#pragma mark -
#pragma mark View life cycle

-(void) viewWillAppear:(BOOL)animated {
    
    UIView *masterView = [[UIApplication sharedApplication].delegate window].rootViewController.view;
    
    //
    //
    
    [self.containerView insertSubview:self.canvas atIndex:0];
    
    //
    //
    
    UIView *brightnessView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    brightnessView.backgroundColor = [UIColor whiteColor];
    
    [self.containerView insertSubview:brightnessView atIndex:0];
    
    //
    //
    
    [self.containerView insertSubview:[[UIImageView alloc] initWithImage:[masterView screenshot]] atIndex:0];
    
    //
    //
    
    [self.scrollView addSubview:self.containerView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
    //
    //
    
    CGSize navigationBarSize = self.navigationBar.frame.size;
    CGSize bottomBarSize = self.bottomBar.frame.size;
    CGSize scrollViewSize = self.scrollView.frame.size;
    
    self.navigationBar.frame = CGRectMake(0, - navigationBarSize.height, navigationBarSize.width, navigationBarSize.height);
    self.bottomBar.frame = CGRectMake(0, masterView.frame.size.height + bottomBarSize.height, bottomBarSize.width, bottomBarSize.height);
    //self.scrollView.frame = CGRectMake(0, 0, masterView.frame.size.width, masterView.frame.size.height);
    
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
        
        brightnessView.alpha = 0.0f;
        self.navigationBar.frame = CGRectMake(0, 0, navigationBarSize.width, navigationBarSize.height);
        self.bottomBar.frame = CGRectMake(0, masterView.frame.size.height - bottomBarSize.height, bottomBarSize.width, bottomBarSize.height);
        self.scrollView.frame = CGRectMake(0, navigationBarSize.height, scrollViewSize.width ,masterView.frame.size.height - navigationBarSize.height - bottomBarSize.height);
        
    } completion:^(BOOL finished){
        if (finished) {
            NSLog(@"RUTrakViewController - Intro Complete");
        }
    }];
    
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    [view addSubview:self.scrollView];
    [view addSubview:self.navigationBar];
    [view addSubview:self.bottomBar];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.client = [[RUTrelloHttpClient alloc] initWithBaseURL:[NSURL URLWithString:kTrelloBaseURL] key:self.consumerKey secret:self.consumerSecret];
    
    NSLog(@"RUTrakViewController - isUserAuthorized: %@", ((self.isUserAuthorized) ? @"YES" : @"NO"));
    
    if (self.isUserAuthorized && !self.defaultBoard && !self.defaultList) {
        [self getMemeberBoards];
    }
    
    [self setupNavigationBar];
    [self setupToolBar];
    [self setupLabelsView];
    
    [self setupHUD];
    
    //This gesture will hide labelView
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [self.containerView addGestureRecognizer:singleTap];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [self handleModalOffset:orientation];
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(NSInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark - RUTrackViewController private implementation

-(void) setupNavigationBar {
        
    [self.loginButton setSelected:self.isUserAuthorized];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc]	initWithCustomView:self.cancelButton];
    UIBarButtonItem *loginButtonItem = [[UIBarButtonItem alloc]	initWithCustomView:self.loginButton];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Trak"];
    navItem.leftBarButtonItem = cancelButtonItem;
    navItem.rightBarButtonItem = loginButtonItem;
    navItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Trak.bundle/logo.png"]];
    
    [self.navigationBar pushNavigationItem:navItem animated:YES];        
}

-(void) setupToolBar {
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *editButton = [UIButton buttonFromImageNamed:@"Trak.bundle/edit.png"];
    [editButton setImage:[UIImage imageNamed:@"Trak.bundle/edit_selected.png"] forState:UIControlStateHighlighted];
    [editButton setImage:[UIImage imageNamed:@"Trak.bundle/edit_selected.png"] forState:UIControlStateSelected];
    [editButton addTarget:self action:@selector(handleEdit:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *textButton = [UIButton buttonFromImageNamed:@"Trak.bundle/text.png"];
    [textButton setImage:[UIImage imageNamed:@"Trak.bundle/text_selected.png"] forState:UIControlStateHighlighted];
    [textButton setImage:[UIImage imageNamed:@"Trak.bundle/text_selected.png"] forState:UIControlStateSelected];
    [textButton addTarget:self action:@selector(handleInputText:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *labelButton = [UIButton buttonFromImageNamed:@"Trak.bundle/label.png"];
    [labelButton setImage:[UIImage imageNamed:@"Trak.bundle/label_selected.png"] forState:UIControlStateHighlighted];
    [labelButton setImage:[UIImage imageNamed:@"Trak.bundle/label_selected.png"] forState:UIControlStateSelected];
    [labelButton addTarget:self action:@selector(handleLabels:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sendButton = [UIButton buttonFromImageNamed:@"Trak.bundle/send.png"];
    [sendButton setImage:[UIImage imageNamed:@"Trak.bundle/send_selected.png"] forState:UIControlStateHighlighted];
    [sendButton addTarget:self action:@selector(handleSend:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *editBarItem = [[UIBarButtonItem alloc]	initWithCustomView:editButton];
    UIBarButtonItem *textBarItem = [[UIBarButtonItem alloc]	initWithCustomView:textButton];
    UIBarButtonItem *labelsBarItem = [[UIBarButtonItem alloc]	initWithCustomView:labelButton];
    UIBarButtonItem *sendBarItem = [[UIBarButtonItem alloc]	initWithCustomView:sendButton];
    
    [self.bottomBar setItems:@[flexibleSpace,editBarItem,flexibleSpace,textBarItem,flexibleSpace,labelsBarItem,flexibleSpace,sendBarItem,flexibleSpace]];
}

-(void) setupLabelsView {
    CGRect frame = self.labelsView.frame;
    frame.origin.y = self.bottomBar.frame.origin.y + self.bottomBar.frame.size.height;
    self.labelsView.frame = frame;
    [self.view insertSubview:self.labelsView belowSubview:self.bottomBar];
}

-(void) setupHUD {
    //
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.cornerRadius = 0;
    self.HUD.color = [UIColor whiteColor];
    self.HUD.labelFont = [UIFont boldSystemFontOfSize:16];
    self.HUD.activityIndicatorViewColor = [UIColor colorWithRed:72.0f/255.0f green:192.0f/255.0f blue:206.0f/255.0f alpha:1.0f];
    //
    self.HUD.labelTextColor = [UIColor colorWithRed:178.0f/255.0f green:178.0f/255.0f blue:178.0f/255.0f alpha:1.0f];
    self.HUD.detailsLabelTextColor = [UIColor colorWithRed:204.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1.0f];
    [self.view addSubview:self.HUD];
}

-(void) handleModalOffset:(UIInterfaceOrientation)orientation {
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.modal.offsetY = 108;
    } else if (UIInterfaceOrientationIsLandscape(orientation)){
        self.modal.offsetY = 81;
    }
}

-(void) showLabelsViewWithButton:(UIButton *)sender {
    
    float buttonXmid = sender.frame.origin.x + sender.frame.size.width/2;
    
    // 195.0 = arrowX
    // 34 = 195 - labelsFrame.size.width/2 =  
    float labelX = buttonXmid - self.labelsView.frame.size.width/2 - 34;
    
    CGSize labelsSize = self.labelsView.frame.size;
    
    self.labelsView.alpha = 0.0f;
    self.labelsView.frame = CGRectMake(labelX, self.bottomBar.frame.origin.y + self.bottomBar.frame.size.height, labelsSize.width, labelsSize.height);
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
        
        self.labelsView.alpha = 1.0f;
        self.labelsView.frame = CGRectMake(labelX, self.bottomBar.frame.origin.y - labelsSize.height - 1.0f  , labelsSize.width, labelsSize.height);
        
    } completion:^(BOOL finished){
        if (finished) {
            //do something
        }
    }];
}

-(void) hideLabelsView {
    
    CGSize labelsSize = self.labelsView.frame.size;
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
        
        self.labelsView.alpha = 0.0f;
        self.labelsView.frame = CGRectMake(self.bottomBar.frame.origin.x, self.bottomBar.frame.origin.y + self.bottomBar.frame.size.height, labelsSize.width, labelsSize.height);
        
    } completion:^(BOOL finished){
        if (finished) {
            //do something
        }
    }];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    [self hideLabelsView];
}

-(void) dismissViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRUTrakViewControllerClosedNotification object:nil];
    }];
}



#pragma mark -
#pragma mark - UITextViewDelegate implementation

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if (![self.feedback isEqualToString:textView.text]) {
        [textView setText:@""];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        textView.delegate = nil;
        
        NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([text length] > 0) {
            self.feedback = text;
        }
        
        [self.modal hide];
        
        return FALSE;
    }
    return TRUE;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

#pragma mark -
#pragma mark - User Input

- (IBAction)handleEdit:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    
    [self.scrollView setScrollEnabled:!self.scrollView.scrollEnabled];
    [self.canvas setUserInteractionEnabled:!self.scrollView.scrollEnabled];
    
    [self hideLabelsView];
}

- (IBAction)handleInputText:(UIButton *)sender {

    kRNDefaultBlurScale = 0.1;
    
    [sender setEnabled:NO];
    
    UIView *textInputView = [[[NSBundle mainBundle] loadNibNamed:@"RUTextInputView"  owner:self    options:nil] lastObject];
    UIView *containerView = [RUTextContainerView containerViewWithTextView:textInputView];
    
    //
    //
    
    UITextView *dummyTextView = (UITextView *)[textInputView viewWithTag:99];
    [dummyTextView becomeFirstResponder];
    
    UITextView *textView = (UITextView *)[textInputView viewWithTag:1];
    if (self.feedback) {
        textView.text = self.feedback;
        [textView becomeFirstResponder];
    }
    textView.delegate = (id) self;
    
    //
    //
    
    self.modal = [[RNBlurModalView alloc] initWithParentView:self.view view:containerView];
    [self.modal hideCloseButton:YES];
    [self.modal hideCloseButton:YES];
    
    self.modal.startTransform = CGAffineTransformMakeTranslation(0,150);
    self.modal.endTransform = CGAffineTransformMakeTranslation(320,0);
    
    self.modal.defaultHideBlock = ^ {
        [sender setEnabled:YES];
    };
    
    [self handleModalOffset:self.interfaceOrientation];
    [self.modal show];
    
    [self hideLabelsView];
}

- (IBAction)handleLabels:(UIButton *)sender {
    [self showLabelsViewWithButton:sender];
}

- (IBAction)handleSend:(UIButton *)sender {
    [self createCard];
    [self hideLabelsView];
}

- (IBAction)handleCancel:(UIButton *)sender {
    [self dismissViewController];
}

- (IBAction)handleLogin:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
    
    if (!self.isUserAuthorized) {
        //LOG IN
        [self authorize];
        
    } else {
        //LOG OFF
        if ([self.client deleteCredentialFromKeychainForName:self.serviceName]) {
            [sender setSelected:NO];
            self.client = [[RUTrelloHttpClient alloc] initWithBaseURL:[NSURL URLWithString:kTrelloBaseURL] key:self.consumerKey secret:self.consumerSecret];
        }
    }
    [self hideLabelsView];
}

#pragma mark -
#pragma mark - HTTP requests

-(RUCardModel *) getCardModel {
    
    NSArray *colorNames = @[@"green", @"yellow", @"orange", @"red", @"purple", @"blue"];
    NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:6];
    for (UIButton *button in self.labelsView.buttons) {
        if (button.isSelected) {
            [labels addObject:@{@"name":@"",@"color":colorNames[button.tag]}];
        }
    }
    
    NSDictionary *values =  @{@"name": self.feedback,
                              @"desc": @"Feedback Powered by Trak",
                              @"labels":labels,
                              @"idList": self.defaultList.id };
    
    NSError *err = nil;
    
    RUCardModel *model = [MTLJSONAdapter modelOfClass: RUCardModel.class fromJSONDictionary: values error: &err];
    return model;
}

-(void) authorize {
    
    __weak RUTrakViewController *weakSelf = self;

    [self.client authorize:self.callbackURL appServiceName:self.serviceName success:^(RUTrelloHttpClient *client, AFOAuth1Token *accessToken, id responseObject) {
        
        [weakSelf.loginButton setSelected:YES];
        [weakSelf getMemeberBoards];
    }
    failure:^(NSError *error) {
        
        NSLog(@"RUTrakViewController - Request Error: %@", error);
        
        [UIAlertView showWithError:error];
    }];
}

-(void) getMemeberBoards {
    
    __weak RUTrakViewController *weakSelf = self;
    
    [self.client getAllMemberBoardsWithSuccessBlock:^(RUTrelloHttpClient *client, NSArray *responseObject) {
        
        NSLog(@"RUTrakViewController - Member boards fetched ...");
        
        NSPredicate *boardPredicate = [NSPredicate predicateWithFormat:@"name = %@", weakSelf.defaultBordName];
        NSPredicate *listPredicate = [NSPredicate predicateWithFormat:@"name = %@", weakSelf.defaultListName];
        
        weakSelf.defaultBoard = (RUBoardModel *)[[responseObject filteredArrayUsingPredicate:boardPredicate] lastObject];
        weakSelf.defaultList = (RUListModel *)[[self.defaultBoard.lists filteredArrayUsingPredicate:listPredicate] lastObject];
        
        if (!weakSelf.defaultBoard) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!!"
                                                            message:[NSString stringWithFormat:@"We couldn't find any board named: '%@'", self.defaultBordName]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                                  otherButtonTitles:nil];
            [alert show];

        } else if (!weakSelf.defaultBoard) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!!"
                                                            message:[NSString stringWithFormat:@"We couldn't find any list named: '%@'", self.defaultListName]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
        
        if (weakSelf.cardRequest) {
            weakSelf.cardRequest = NO;
            [weakSelf createCard];
        }
    }
    failure:^(NSError *error) {
        NSLog(@"RUTrakViewController - Request Error: %@", error);
        
        [UIAlertView showWithError:error];
    }];
}

-(void) createCard {
    
    if (self.feedback.length > 0) {
        
        if (self.isUserAuthorized && self.defaultList.id.length > 0) {
        
            __weak RUTrakViewController *weakSelf = self;
            
            self.HUD.labelText = @"Uploading";
            [self.HUD show:YES];
            
            RUCardModel *model = [self getCardModel];
            
            [self.client createCardWithModel:model success:^(RUTrelloHttpClient *client, RUCardModel *responseObject) {
                
                NSLog(@"RUTrakViewController - Card created successfully");
                                
                [weakSelf uploadImage:responseObject.id];
            }
            failure:^(NSError *error) {
                
                NSLog(@"RUTrakViewController - Request Error: %@", error);
                
                [UIAlertView showWithError:error];
                [MBProgressHUD hideHUDForView:self.view animated:NO];

            }];
            
        } else {
            
            self.cardRequest = YES;
            [self authorize];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!!"
                                                        message:@"You can't create a card without any description!"
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles:nil];
        [alert show];

    }
}

-(void) uploadImage:(NSString *)idCard {
    
    __weak RUTrakViewController *weakSelf = self;
    
    [self.client uploadImage:UIImageJPEGRepresentation([self.containerView screenshot], 0.9)
                 idCard:idCard
                success:^(RUTrelloHttpClient *client, id responseObject) {
                    
                    NSLog(@"RUTrakViewController - Imaged uploaded successfully");
                    
                    weakSelf.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Trak.bundle/completed.png"]];
                    weakSelf.HUD.mode = MBProgressHUDModeCustomView;
                    weakSelf.HUD.labelText = @"Completed";
                    [weakSelf performSelector:@selector(dismissViewController) withObject:nil afterDelay:1.0];
                }
                failure:^(NSError *error) {
                    
                    NSLog(@"RUTrakViewController - Request Error: %@", error);
                    
                    [UIAlertView showWithError:error];
                    
                    [MBProgressHUD hideHUDForView:self.view animated:NO];
                    
                }];
}

@end

#pragma mark -
#pragma mark - Helper Classes

@implementation UIAlertView (UIAlertView_RUTrakAdditions)

+(UIAlertView*) showWithError:(NSError*) networkError {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[networkError localizedDescription]
                                                    message:[networkError localizedRecoverySuggestion]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                          otherButtonTitles:nil];
    [alert show];
    return alert;
}
@end


@implementation UIButton (UIButton_RUTrakAdditions)

+(UIButton *) buttonFromImageNamed:(NSString *)name {
    UIImage *buttonImage = [UIImage imageNamed:name];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    return button;
}

@end


@implementation RUCustomNavigationBar

- (void)drawRect:(CGRect)rect {
    UIColor *color = [UIColor colorWithRed:2.0f/255.0f green:138.0f/255.0f blue:186.0f/255.0f alpha:1.0f];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
    CGContextFillRect(context, rect);
}

@end

@implementation RUCustomToolBar

- (void)drawRect:(CGRect)rect {
    UIColor *color = [UIColor colorWithRed:72.0f/255.0f green:192.0f/255.0f blue:206.0f/255.0f alpha:1.0f];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
    CGContextFillRect(context, rect);
}

@end


@implementation RULabelsView

- (void)setup
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Trak.bundle/labels_background.png"]]];
    
    NSArray *buttonImages = @[@{@"normal":@"Trak.bundle/label_green.png",
                               @"selected":@"Trak.bundle/label_green_over.png"},
                             
                             @{@"normal":@"Trak.bundle/label_yellow.png",
                               @"selected":@"Trak.bundle/label_yellow_over.png"},
                               
                             @{@"normal":@"Trak.bundle/label_orange.png",
                               @"selected":@"Trak.bundle/label_orange_over.png"},
                             
                             @{@"normal":@"Trak.bundle/label_red.png",
                               @"selected":@"Trak.bundle/label_red_over.png"},
                             
                             @{@"normal":@"Trak.bundle/label_purble.png",
                               @"selected":@"Trak.bundle/label_purble_over.png"},
                             
                             @{@"normal":@"Trak.bundle/label_blue.png",
                               @"selected":@"Trak.bundle/label_blue_over.png"}];
    
    NSMutableArray *mButtons = [[NSMutableArray alloc] initWithCapacity:[buttonImages count]];
    
    int i = 0;
    for (NSDictionary *info in buttonImages) {
        UIButton *button = [UIButton buttonFromImageNamed:info[@"normal"]];
        button.frame = CGRectMake( 2.0f + ((button.frame.size.width + 1.0f) * i), 2.0f, button.frame.size.width, button.frame.size.height);
        [button setImage:[UIImage imageNamed:info[@"selected"]] forState:UIControlStateSelected];
        [button setTag:i];
        
        [button addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        [mButtons addObject:button];
        
        i++;
    }
    
    self.buttons = [mButtons copy];

}

- (void) handleTap:(UIButton *)sender {
    [sender setSelected:!sender.selected];
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

@end


@implementation RUTextContainerView

#pragma mark - Initialization

+(id) containerViewWithTextView:(UIView *)textView {
        
    CGFloat padding = 17;
    CGRect containerViewRect = CGRectInset(textView.bounds, -padding, -padding);
    
    UIView *containerView = [[RUTextContainerView alloc] initWithFrame:containerViewRect];
    textView.frame = (CGRect){padding, padding, textView.bounds.size};
    
    [containerView addSubview:textView];
    
    return containerView;
}

- (void)setup
{
    CALayer *styleLayer = [[CALayer alloc] init];
    //    styleLayer.cornerRadius = 10;
    //    styleLayer.shadowColor= [[UIColor blackColor] CGColor];
    //    styleLayer.shadowOffset = CGSizeMake(0, 0);
    //    styleLayer.shadowOpacity = 0.5;
    //    styleLayer.borderWidth = 1;
    styleLayer.borderColor = [[UIColor whiteColor] CGColor];
    styleLayer.frame = CGRectInset(self.bounds, 12, 12);
    styleLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    [self.layer addSublayer:styleLayer];
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}


@end

