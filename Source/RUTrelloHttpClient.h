//
//  RUTrelloHttpClient.h
//  Trak
//
//  Created by Raul on 8/13/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "AFOAuth1Client.h"
#import "RUTrelloModels.h"

@interface RUTrelloHttpClient : AFOAuth1Client

@property (nonatomic, readonly) NSString *serviceName;

-(BOOL) authorizeFromKeychainForName:(NSString *) appServiceName;

-(BOOL) deleteCredentialFromKeychainForName:(NSString *)identifier;

-(void) authorize:(NSString *)callBackURL
   appServiceName:(NSString *)keychainAppServiceName
          success:(void (^)(RUTrelloHttpClient *client, AFOAuth1Token *accessToken, id responseObject))success
          failure:(void (^)(NSError *error))failure;

-(void) getAllMemberBoardsWithSuccessBlock:(void (^)(RUTrelloHttpClient *client, NSArray *responseObject))success
                                   failure:(void (^)(NSError *error))failure;

-(void) createCardWithModel:(RUCardModel *)model
                    success:(void (^)(RUTrelloHttpClient *client, RUCardModel *responseObject))success
                    failure:(void (^)(NSError *error))failure;

-(void) uploadImage:(NSData *)imageData
             idCard:(NSString *)cardID
            success:(void (^)(RUTrelloHttpClient *client, id responseObject))success
            failure:(void (^)(NSError *error))failure;
@end