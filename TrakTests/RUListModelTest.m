//
//  RUListModelTest.m
//  Trak
//
//  Created by Raul on 8/5/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "Kiwi.h"
#import "MTLJSONAdapter.h"
#import "RUTrelloModels.h"
#import "AFJSONRequestOperation.h"

SPEC_BEGIN(RUListModelTest)
describe(@"RUListModelTest Test", ^{
    
    context(@"When created from MTLJSONAdapter", ^{
        
        NSDictionary *values = @{
                                 @"closed": @YES,
                                 @"id": @"5",
                                 @"name": @"Raul",
                                 @"idBoard": @"123458xcfvs",
                                 @"pos": @"298",
                                 @"subscribed": @NO,
                                 };

        
        NSError *error = nil;
        
        RUListModel *model = [MTLJSONAdapter modelOfClass: RUListModel.class fromJSONDictionary: values error: &error];
                
        it(@"should exist", ^{
            [model shouldNotBeNil];
        });
        
        it(@"should be equal to TListModel", ^{
            [[model should] beKindOfClass:[RUListModel class]];
        });
        
        it(@"name should be equal to Raul", ^{
            [[model.name should] equal:@"Raul"];
        });
        
        it(@"idBoard should be equal to 123458xcfvs", ^{
            [[model.idBoard should] equal:@"123458xcfvs"];
        });
        
        it(@"should print JSON string", ^{
            NSDictionary *jsonDict = [MTLJSONAdapter JSONDictionaryFromModel:model];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
            NSString *jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
            NSLog(@"%@", jsonString);
        });
        
    });
    
    context(@"When created from REST", ^{
        
        NSString *privateKey = @"d6f2071c12e305011a8e227cbc27e27f";
        NSString *privateToken = @"b30405399847d1f3171c06835ef6f6235457f9bcb2e54678141467d7587e77a4";
        
        NSString *path = [NSString stringWithFormat:@"https://api.trello.com/1/lists/51ccd92aebdd10050800032d?fields=name,closed,idBoard,pos,subscribed&key=%@&token=%@",privateKey,privateToken];
        NSURL *url = [NSURL URLWithString:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        pending(@"should receive data within one second", ^{
            
            __block RUListModel *fetchedModel = nil;
            
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                
                NSError *error = nil;
                fetchedModel = [MTLJSONAdapter modelOfClass: RUListModel.class fromJSONDictionary: JSON error: &error];
                
                /*/
                NSDictionary *jsonDict = [MTLJSONAdapter JSONDictionaryFromModel:fetchedModel];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
                NSString *jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
                NSLog(@"%@", jsonString);
                NSLog(@"-----********");
                //*/
                
            } failure:nil];
            
            [operation start];
            
            
             [[expectFutureValue(fetchedModel) shouldEventually] beNonNil];
             [[expectFutureValue(fetchedModel.name) shouldEventuallyBeforeTimingOutAfter(2.0)] equal:@"Pendientes"];
        });
        
        
    });
});
SPEC_END

