//
//  SAPGatewayClient.h
//  sflightdemo
//
//  Created by René on 24-10-13.
//  Copyright (c) 2013 vanmil.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SAPGatewayClient;

@interface SAPGatewayClient : NSObject

+ (SAPGatewayClient *)sharedSAPGatewayClient;

- (void)listFlightsWithSuccess:(void (^)(NSMutableArray *flights))success
                       failure:(void (^)(NSError *error))failure;

@end
