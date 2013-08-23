//
//  GWTCardModelTest.m
//  Trak
//
//  Created by Raul on 8/13/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "Kiwi.h"
#import "MTLJSONAdapter.h"
#import "RUTrelloModels.h"

SPEC_BEGIN(RUCardModelTest)
describe(@"RUCardModelTest Test", ^{
    
    context(@"When created from MTLJSONAdapter", ^{
        
        NSDictionary *values =  @{@"name":@"Prueba desde el simulador",
                                  @"desc": @"creado con Trak app",
                                  @"labels": @[ @{ @"name":@"Red Label",
                                                   @"color":@"red"},
                                                @{ @"name":@"Blue Label",
                                                   @"color":@"blue"} ],
                                  @"idList": @"518c3160eddac1351e0042f1"};

            
        NSError *error = nil;
        
        RUCardModel *model = [MTLJSONAdapter modelOfClass: RUCardModel.class fromJSONDictionary: values error: &error];
        
        it(@"should exist", ^{
            [model shouldNotBeNil];
        });
        
        it(@"should be equal to GWTLabelsModel", ^{
            [[model should] beKindOfClass:[RUCardModel class]];
        });
        
        it(@"name should be equal to 'Prueba desde el simulador'", ^{
            [[model.name should] equal:@"Prueba desde el simulador"];
        });
        
        it(@"should have two labels objects", ^{
            [[theValue([model.labels count]) should] equal:2 withDelta:001];
        });
        
        it(@"lists Items should be kind of 'GWTLabelModel' class", ^{
            
            for (id item in model.labels) {
                //block(item);
                [[item should] beKindOfClass:[RULabelModel class]];
            };
            
            [[((RULabelModel *)model.labels[0]).name should] equal:@"Red Label"];
            
            NSMutableArray *labelNames = [[NSMutableArray alloc] initWithCapacity:[model.labels count]];
            
            for (RULabelModel* label in model.labels) {
                [labelNames addObject:label.color];
            }

            
            NSString *colors = [labelNames componentsJoinedByString:@","];
            
            [[colors should] equal:@"red, blue"];
            
        });
        
    });
});
SPEC_END
