
<img src="http://f.cl.ly/items/0l3m233D1D3v3s3m1B01/track-blue-592x314.png" alt="Trak" style="width: 298px; height:157px;"/>


A drop-in component for reporting bugs using [Trello](https://trello.com/) [API](https://trello.com/docs/).

###Features

* Captures a screenshot of the current state of your app. (this will be included as an attachment in to your Trello card)
* Hand drawing over the screenshot. 
* Apply multiples labels (based on Trello labels colors)
* Add description.

<a href="http://f.cl.ly/items/3v1a1o3H3D0e3R1F0h0h/trak_screenshot_02.jpg">
<img src="http://f.cl.ly/items/3v1a1o3H3D0e3R1F0h0h/trak_screenshot_02.jpg" alt="Trak" style="width: 160px; height:302px; float:left;"/>
</a>
<a href="http://f.cl.ly/items/0w2k2S0S0M2G0G0l431T/trak_screenshot_01.jpg">
<img src="http://f.cl.ly/items/0w2k2S0S0M2G0G0l431T/trak_screenshot_01.jpg" alt="Trak" style="width: 160px; height:302px; float:left;"/>
</a>
<a href="http://f.cl.ly/items/3N2w3y3Y1L0x2T0f1Z25/trak_screenshot_03.jpg">
<img src="http://f.cl.ly/items/3N2w3y3Y1L0x2T0f1Z25/trak_screenshot_03.jpg" alt="Trak" style="width: 160px; height:302px; float:left;"/>
</a>
<a href="http://f.cl.ly/items/1Y0d0x2J3k3R1n3m0e03/trak_screenshot_05.jpg">
<img src="http://f.cl.ly/items/1Y0d0x2J3k3R1n3m0e03/trak_screenshot_05.jpg" alt="Trak" style="width: 160px; height:302px; float:left;"/>
</a>

** *for now only supports iPhone in portrait mode.**

Watch it in action! [https://vimeo.com/72994059](https://vimeo.com/72994059)

#Installation

###With CocoaPods

coming soon.

###Manual installation

I´m in the middle of the process for creating the `podspec` file, meanwhile you need to drag & drop the ./Source folder into your project, then create a `podfile` adding the following dependencies:

``` ruby
pod 'Mantle', '~> 1.2'
pod 'MLScreenshot', '~> 1.0.3'
pod 'RUCanvasView', :git => 'https://github.com/rauluranga/RUCanvasView'
pod 'MBProgressHUD', :git => 'https://github.com/rauluranga/MBProgressHUD.git', :commit => '95baad6af9712c1cd77e97f9d5c174072082227f'
pod 'AFOAuth1Client', :git => 'https://github.com/rauluranga/AFOAuth1Client.git', :commit => '7e4e3fcb451bf4719aad947bc2883b00c30d682a'
pod 'RNBlurModalView', :git => 'https://github.com/rauluranga/RNBlurModalView.git', :commit => '535c68289f0917bbbbefa16e87e08de171b15618'
```

finally run `pod install`.

# Implementation 

Trak depends on [AFOAuth1Client](https://github.com/AFNetworking/AFOAuth1Client) so you need to register your application to [launch from a custom URL scheme](http://iosdevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html), and use that with the path /success as your callback URL. The callback for the custom URL scheme should send a notification, which will complete the OAuth transaction.

once you have that, copy the following code:


``` objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    .
    .
    .    
    NSDictionary *defaults = @{kTrelloConsumerKey:@"YOUR_CONSUMER_KEY",
                                kTrelloConsumerSecret:@"YOUR_CONSUMER_SECRET",
                                kTrelloDefaultBordName:@"My Project Board",
                                kTellokDefaultListName:@"Bugs",
                                kOAuthCallBackURL:@"trak://success",
                                kDefaultServiceName:@"My Custom App Service Name" };
        
    [[Trak sharedInstance] setupWithDictionary:defaults];
            
    return YES;
}
```
You can get your `CONSUMER_KEY` & `CONSUMER_SECRET` from [Trello API](https://trello.com/1/appKey/generate)

to respond to the custom URL scheme on iOS copy the following code:

``` objective-c
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    [[Trak sharedInstance] applicationLaunchOptionsWithURL:url];
    
    return YES;
}
```

###Presenting Trak via Gesture 
You can present the Trak prompt via a three-finger-SwipeDown with the following code:

``` objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    .
    .
    .  
    [[Trak sharedInstance] installGestureOnWindow:self.window];
    return YES;
}
```

###DIY Presentation

You can call `-presentIssueViewControllerOnViewController` to show Trak prompt after a specific event.

``` objective-c
- (IBAction)show:(UIButton *)sender {
    [[Trak sharedInstance] presentTrakViewControllerOnViewController:self];
}
```


