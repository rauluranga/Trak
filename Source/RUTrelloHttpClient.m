//
//  RUTrelloHttpClient.m
//  Trak
//
//  Created by Raul on 8/13/13.
//  Copyright (c) 2013 Raul Uranga. All rights reserved.
//

#import "RUTrelloHttpClient.h"
#import "AFJSONRequestOperation.h"

@implementation RUTrelloHttpClient

@synthesize serviceName = _serviceName;

-(BOOL) authorizeFromKeychainForName:(NSString *) appServiceName {
    AFOAuth1Token *oauth = [AFOAuth1Token retrieveCredentialWithIdentifier:appServiceName];
    if (oauth && !oauth.expired) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        self.accessToken = oauth;
        return YES;
    }
    return NO;
}

-(BOOL) deleteCredentialFromKeychainForName:(NSString *)identifier {
    return [AFOAuth1Token deleteCredentialWithIdentifier:identifier];
}

-(void) authorize:(NSString *)callBackURL appServiceName:(NSString *)keychainAppServiceName success:(void (^)(RUTrelloHttpClient *client, AFOAuth1Token *accessToken, id responseObject))success
                          failure:(void (^)(NSError *error))failure {
    
    _serviceName = keychainAppServiceName;
    
    [self authorizeUsingOAuthWithRequestTokenPath:@"1/OAuthGetRequestToken"
                                         userAuthorizationPath:@"1/OAuthAuthorizeToken"
                                                   callbackURL:[NSURL URLWithString:callBackURL]
                                               accessTokenPath:@"1/OAuthGetAccessToken"
                                                  accessMethod:@"POST"
                                                         scope:@"read,write"
                                                       success:^(AFOAuth1Token *accessToken, id responseObject) {
                                                           
                                                           [AFOAuth1Token storeCredential:accessToken withIdentifier:keychainAppServiceName];
                                                           
                                                           [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
                                                           [self setDefaultHeader:@"Accept" value:@"application/json"];
                                                           
                                                           if (success) {
                                                               success(self, accessToken, responseObject);
                                                           }
                                                       }
                                                       failure:^(NSError *error) {
                                                           if (failure) {
                                                               failure(error);
                                                           }
                                                       }];

}

-(void) getAllMemberBoardsWithSuccessBlock:(void (^)(RUTrelloHttpClient *client, NSArray *responseObject))success
                                   failure:(void (^)(NSError *error))failure {
    [self getPath:@"1/members/me/boards"
                    parameters:@{@"lists":@"open", @"fields": @"name,desc,labelNames"}
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           
                           NSMutableArray *array = [[NSMutableArray alloc] init];
                           
                           //NSLog(@"responseObject: %@", responseObject);
                           
                           for (NSDictionary *dict in responseObject) {
                               NSError *error = nil;
                               RUBoardModel *boardModel = [MTLJSONAdapter modelOfClass: RUBoardModel.class fromJSONDictionary: dict error: &error];
                               [array addObject:boardModel];
                           }
                           
                           if (success) {
                               success(self, [array copy]);
                           }
                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           
                           if (failure) {
                               failure(error);
                           }                           
                       }];
    
}

-(void) createCardWithModel:(RUCardModel *)model
                    success:(void (^)(RUTrelloHttpClient *client, RUCardModel *responseObject))success
                    failure:(void (^)(NSError *error))failure {
    NSMutableArray *labelNames = [[NSMutableArray alloc] initWithCapacity:[model.labels count]];
    
    for (RULabelModel* label in model.labels) {
        [labelNames addObject:label.color];
    }
    
    [self postPath:@"1/cards"
                     parameters:@{@"name": model.name,
                                  @"desc": model.desc,
                                  @"pos": @"bottom",
                                  @"due": @"null",
                                  @"labels": [labelNames componentsJoinedByString:@","],
                                  @"idList": model.idList}
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            NSError *error = nil;
                            RUCardModel *cardModel = [MTLJSONAdapter modelOfClass: RUCardModel.class fromJSONDictionary:responseObject error: &error];
                        
                            if (success) {
                                success(self, cardModel);
                            }                            
                        }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            
                            if (failure) {
                                failure(error);
                            }
                        }];
}

-(void) uploadImage:(NSData *)imageData
             idCard:(NSString *)cardID
            success:(void (^)(RUTrelloHttpClient *client, id responseObject))success
            failure:(void (^)(NSError *error))failure {
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:MM:SS"];
    NSString* date_str = [formatter stringFromDate:date];
    //
    //
    //
    //
    NSString *imageName = [NSString stringWithFormat:@"Image-%@.jpg", date_str];
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST"
                                                                   path:[NSString stringWithFormat:@"1/cards/%@/attachments", cardID]
                                                             parameters:@{@"file": @"null",
                                                                           @"url": @"null",
                                                                          @"name": imageName,
                                                                      @"mimeType": @"image/jpeg"}
                                              constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                               
                                                               [formData appendPartWithFileData: imageData
                                                                                           name:@"file"
                                                                                       fileName:imageName
                                                                                       mimeType:@"image/jpeg"];
                                                               
                                                           }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            success(self, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
//        if([operation.response statusCode] == 403){
//            NSLog(@"Upload Failed");
//            return;
//        }
//        
//        NSLog(@"error: %@", [operation error]);
//        
        
    }];
    
    [operation start];
    
}



@end
