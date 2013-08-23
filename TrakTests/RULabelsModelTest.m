//
//  RULabelsModelTest.m
//  Trak
//
//  Created by Raul on 8/5/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "Kiwi.h"
#import "MTLJSONAdapter.h"
#import "RUTrelloModels.h"

SPEC_BEGIN(RULabelsModelTest)
describe(@"RULabelsModelTest Test", ^{
    
    context(@"When created from MTLJSONAdapter", ^{
        
        NSDictionary *values =  @{
                                  @"yellow"  : @"Yellow Label",
                                  @"red"   : @"Red Label",
                                  @"purple"   : @"Purple Label",
                                  @"orange"   : @"Orange Label",
                                  @"green"   : @"Green Label",
                                  @"blue"   : @"Blue Label",
                                  };
        
        
        NSError *error = nil;
        
        RULabelNamesModel *model = [MTLJSONAdapter modelOfClass: RULabelNamesModel.class fromJSONDictionary: values error: &error];
        
        it(@"should exist", ^{
            [model shouldNotBeNil];
        });
        
        it(@"should be equal to GWTLabelsModel", ^{
            [[model should] beKindOfClass:[RULabelNamesModel class]];
        });
        
        it(@"red should be equal to 'Red Label'", ^{
            [[model.red should] equal:@"Red Label"];
        });
        
    });
});
SPEC_END
