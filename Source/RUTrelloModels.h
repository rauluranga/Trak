//
//  RUTrelloModels.h
//  Trak
//
//  Created by Raul on 8/14/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@class RULabelNamesModel;

@interface RUBoardModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly, copy) NSString *id;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) RULabelNamesModel *labelNames;
@property (nonatomic, readonly, copy) NSArray *lists;

@end


//##
//##
//##


@interface RUCardModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly, copy) NSString *id;
@property (nonatomic, readonly, copy) NSString *desc;
@property (nonatomic, readonly, copy) NSString *idList;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSArray *labels;

@end


//##
//##
//##



@interface RULabelModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly,copy) NSString *color;
@property (nonatomic, readonly,copy) NSString *name;

@end


//##
//##
//##



@interface RULabelNamesModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly, copy) NSString *yellow;
@property (nonatomic, readonly, copy) NSString *red;
@property (nonatomic, readonly, copy) NSString *purple;
@property (nonatomic, readonly, copy) NSString *orange;
@property (nonatomic, readonly, copy) NSString *green;
@property (nonatomic, readonly, copy) NSString *blue;

@end


//##
//##
//##



@interface RUListModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly,copy) NSString *id;
@property (nonatomic, readonly,copy) NSString *name;
@property (nonatomic, readonly, assign) BOOL closed;
@property (nonatomic, readonly,copy) NSString *idBoard;
@property (nonatomic, readonly,copy) NSString *pos;
@property (nonatomic, readonly, assign) BOOL subscribed;

@end

