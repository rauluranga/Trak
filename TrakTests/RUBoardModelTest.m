//
//  GWTBoardModelTest.m
//  Trak
//
//  Created by Raul on 8/5/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "Kiwi.h"
#import "MTLJSONAdapter.h"
#import "RUTrelloModels.h"
#import "AFJSONRequestOperation.h"

SPEC_BEGIN(RUBoardModelTest)
describe(@"RUBoardModelTest Test", ^{
    
    context(@"When created from MTLJSONAdapter", ^{
        
        NSDictionary *values =  @{
                                  @"id"  : @"axricmsiofl10",
                                  @"name"   : @"Sample Board",
                                  @"labelNames"   : @{
                                          @"yellow"  : @"Yellow Label",
                                          @"red"   : @"Red Label",
                                          @"purple"   : @"Purple Label",
                                          @"orange"   : @"Orange Label",
                                          @"green"   : @"Green Label",
                                          @"blue"   : @"Blue Label",
                                          },
                                  @"lists"   : @[@{
                                                     @"closed": @YES,
                                                     @"id": @"ewpv4c5",
                                                     @"name": @"Bugs",
                                                     @"idBoard": @"axricmsiofl10",
                                                     @"pos": @"298",
                                                     @"subscribed": @NO,
                                                     },
                                                 @{
                                                     @"closed": @NO,
                                                     @"id": @"wetbnc5",
                                                     @"name": @"ToDo",
                                                     @"idBoard": @"axricmsiofl10",
                                                     @"pos": @"28",
                                                     @"subscribed": @NO,
                                                     }],
                                  };
        
        
        NSError *error = nil;
        
        RUBoardModel *model = [MTLJSONAdapter modelOfClass: RUBoardModel.class fromJSONDictionary: values error: &error];
        
        it(@"should exist", ^{
            [model shouldNotBeNil];
        });
        
        it(@"should be kind of GWTBoardModel class", ^{
            [[model should] beKindOfClass:[RUBoardModel class]];
        });
        
        it(@"name should be equal to 'Sample Board'", ^{
            [[model.name should] equal:@"Sample Board"];
        });
        
        it(@"name should be equal to 'axricmsiofl10'", ^{
            [[model.id should] equal:@"axricmsiofl10"];
        });
        
        it(@"labelNames should be kind of 'GWTLabelsModel' class", ^{
            [[model.labelNames should] beKindOfClass:[RULabelNamesModel class]];
            [[model.labelNames.blue should] equal:@"Blue Label"];
        });
        
        it(@"should have two list objects", ^{
            [[theValue([model.lists count]) should] equal:2 withDelta:001];
        });
        
        it(@"lists Items should be kind of 'GWTListModel' class", ^{
            
            for (id item in model.lists) {
                //block(item);
                [[item should] beKindOfClass:[RUListModel class]];
            };
            
            [[((RUListModel *)model.lists[0]).name should] equal:@"Bugs"];
            
        });
        
    });
    
    
    context(@"When created from REST", ^{
        
        NSString *privateKey = @"d6f2071c12e305011a8e227cbc27e27f";
        NSString *privateToken = @"58d560158ef5651d13b78f74685e1059ab7ec50288d0cbc09b70822a8b3b03b6";

        NSString *path = [NSString stringWithFormat:@"https://api.trello.com/1/boards/518bec1424dcea0031005ab1?lists=open&list_fields=name&fields=name,labelNames&key=%@&token=%@",privateKey,privateToken];
        NSURL *url = [NSURL URLWithString:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        pending(@"should receive data within one second", ^{
            
            __block RUBoardModel *fetchedModel = nil;
            
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                
                NSError *error = nil;
                fetchedModel = [MTLJSONAdapter modelOfClass: RUBoardModel.class fromJSONDictionary: JSON error: &error];
                
            } failure:nil];
            
            [operation start];
            
            [[expectFutureValue(fetchedModel) shouldEventually] beNonNil];
            [[expectFutureValue(fetchedModel.name) shouldEventuallyBeforeTimingOutAfter(2.0)] equal:@"JeepPS QA"];
            [[expectFutureValue(fetchedModel.labelNames.red) shouldEventuallyBeforeTimingOutAfter(2.0)] equal:@"Buscar ruta"];
            [[expectFutureValue(((RUListModel *)fetchedModel.lists[0]).name) shouldEventuallyBeforeTimingOutAfter(2.0)] equal:@"Pendientes"];
        });
        
        
    });
    
});
SPEC_END
