//
//  SAPGatewayClient.m
//  sflightdemo
//
//  Created by René on 24-10-13.
//  Copyright (c) 2013 vanmil.org. All rights reserved.
//

#import "SAPGatewayClient.h"

#import "AFNetworking.h"

#warning TODO change this URL to the correct URL and port for your SAP Gateway system
static const NSString *baseUrl = @"https://yoursapserver.local:<port>/sap/opu/odata/sap/zsflightgw_srv/";

@interface SAPGatewayClient ()
@property (nonatomic) AFHTTPRequestOperationManager *manager;
@property (nonatomic) NSMutableArray *cachedMaterials;
@end

@implementation SAPGatewayClient

+ (SAPGatewayClient *)sharedSAPGatewayClient {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        [self setManager:[AFHTTPRequestOperationManager manager]];
#warning TODO change username and password
        NSURLCredential *credential = [NSURLCredential credentialWithUser:@"username" password:@"password" persistence:NSURLCredentialPersistenceNone];
        [[self manager] setCredential:credential];
        // Always use JSON and make sure everything is mutable
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        [[self manager] setResponseSerializer:responseSerializer];
    }
    return self;
}

- (void)listFlightsWithSuccess:(void (^)(NSMutableArray *flights))success
                       failure:(void (^)(NSError *error))failure;
{
    /*
     The URL to SAP Gateway, which we'll send the GET request to. We want to list the entire FlightSet.
     Make sure to add the '$format=json' parameter, so the response will be formatted in JSON
     */
    NSString *urlString = [NSString stringWithFormat:@"%@FlightSet?$format=json", baseUrl];
    /*
     Perform the GET request.
     If the request succeeds, the list of flights is read from the response. SAP Gateway always returns a single JSON object, which always contains a single property called 'd', which always contains a single array called 'results'.
     For this call the 'results' array contains all the flights.
     After reading the flights array, the success callback is executed providing the retrieved array of flights.
     */
    [[self manager] GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *flights = [[(NSMutableDictionary *)responseObject valueForKey:@"d"] valueForKey:@"results"];
        if (success) {
            success(flights);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (failure) {
            failure(error);
        }
    }];
}

@end
