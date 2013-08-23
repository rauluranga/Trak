//
//  RUTrelloModels.m
//  Trak
//
//  Created by Raul on 8/14/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "RUTrelloModels.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"


#pragma mark -
#pragma mark RUBoardModel

@implementation RUBoardModel

// keys in the JSON you care about, and which property they map to.  @{ localPropertyName : jsonKey, ... }
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id"  : @"id",
             @"name"   : @"name",
             @"labelNames"   : @"labelNames",
             @"lists"   : @"lists",
             };
}

+ (NSValueTransformer *)labelNamesJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[RULabelNamesModel class]];
}

+ (NSValueTransformer *)listsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[RUListModel class]];
}

@end

#pragma mark -
#pragma mark RUCardModel

@implementation RUCardModel

// keys in the JSON you care about, and which property they map to.  @{ localPropertyName : jsonKey, ... }
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id"  : @"id",
             @"desc"   : @"desc",
             @"idList"   : @"idList",
             @"name"   : @"name",
             @"labels"   : @"labels",
             };
}

+ (NSValueTransformer *)labelsJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[RULabelModel class]];
}

@end

#pragma mark -
#pragma mark RULabelModel

@implementation RULabelModel

// keys in the JSON you care about, and which property they map to.  @{ localPropertyName : jsonKey, ... }
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"color"  : @"color",
             @"name"   : @"name",
             };
}

@end

#pragma mark -
#pragma mark RULabelNamesModel

@implementation RULabelNamesModel

// keys in the JSON you care about, and which property they map to.  @{ localPropertyName : jsonKey, ... }
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"yellow"  : @"yellow",
             @"red"   : @"red",
             @"purple"   : @"purple",
             @"orange"   : @"orange",
             @"green"   : @"green",
             @"blue"   : @"blue",
             };
}

@end

#pragma mark -
#pragma mark RUListModel

@implementation RUListModel

// keys in the JSON you care about, and which property they map to.  @{ localPropertyName : jsonKey, ... }
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id"  : @"id",
             @"name"   : @"name",
             @"closed"   : @"closed",
             @"idBoard"   : @"idBoard",
             @"pos"   : @"pos",
             @"subscribed"   : @"subscribed",
             };
}

@end