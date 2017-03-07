//
//  parser.m
//  ZomatoDempApp
//
//  Created by Mohini on 05/03/17.
//  Copyright © 2017 Mohini. All rights reserved.
//

#import "DataParser.h"

@implementation DataParser

+(void) getCategories :(void (^)(NSArray *categories,NSString * errorMsg))callBackToMainVC
{
    __block NSURLRequest *request;
    
    [Services makeRequest:ZOMATO_CATEGORY_FIELD withData:nil withCompletionHandler:^(NSURLRequest *recievedRequest)
    {
        request=recievedRequest;
    }];
    [Services sendRequest:request completionHandler:^(NSDictionary *data, NSString *errorMsg)
     {
		NSMutableArray *categories=[[NSMutableArray alloc]init];
		if(errorMsg==nil)
		{
		 for(NSDictionary *obj in data[@"categories"])
             {
                 Category *category = [[Category alloc] initWithDictionary:obj];
                 [categories addObject:category];
			 }
		}
         callBackToMainVC(categories,errorMsg);
    }];
}




+(NSURL *) composeURLWithParametersForLOCATION :(double)lat withLongitude :(double)lon {
		NSURLComponents *components=[NSURLComponents componentsWithString:ZOMATO_URL];
        NSString *latitude=[NSString stringWithFormat:@"%.20f", lat];
        NSString *longitude=[NSString stringWithFormat:@"%.20f", lon];
        NSURLQueryItem *latd=[NSURLQueryItem queryItemWithName:@"lat" value:latitude];
        NSURLQueryItem *lond=[NSURLQueryItem queryItemWithName:@"lon" value:longitude];
		components.queryItems=@[latd,lond];
		NSURL *url=components.URL;
		return url;
	
	
}



+(void) getLocation :(double)lat withLongitude :(double)lon withCompletionHandler :(void (^)(CityDetails *city,NSString *errorMsg))callBackToMainVC{
    NSURL *url=[DataParser composeURLWithParametersForLOCATION :lat withLongitude :(double) lon];
	__block NSURLRequest *request;
		NSString *urlString=url.absoluteString;
		[Services makeRequestWithParametres:urlString withService:@"cities" withCompletionHandler:^(NSURLRequest *recievedRequest)
		 {
			request=recievedRequest;
             __block CityDetails *currentCity;
			[Services sendRequest:request completionHandler:^(NSDictionary *data, NSString *errorMsg)
		   {
			// NSMutableArray *cityDetails=[[NSMutableArray alloc]init];
			 if(errorMsg==nil)
			 {
				 NSArray *array= data[@"location_suggestions"];
                 CityDetails *city=[[CityDetails alloc]initWithDictionary:array[0]];
                 currentCity=city;
			 }
               
			 callBackToMainVC(currentCity,errorMsg);
		 }];
		}];

	
	
}



+(void) getDetailsAboutCity :(NSString *)citySearch withCompletionHandler :(void (^) (NSArray * cityDetails ,NSString * errorMsg))callBackToMainVC
{
	__block NSURLRequest *request;
	//NSURL *url=[DataParser composeURLWithParameters:citySearch withParameter2:5];
	//NSString *urlString=url.absoluteString;
	[Services makeRequestWithParametres:@"https://developers.zomato.com/api/v2.1/<service>?q=delhi&count=10"
							withService:@"cities" withCompletionHandler:^(NSURLRequest *recievedRequest)
	 {
		request=recievedRequest;
		[Services sendRequest:request completionHandler:^(NSDictionary *data, NSString *errorMsg)
	   {
		 NSMutableArray *cityDetails=[[NSMutableArray alloc]init];
		 if(errorMsg==nil)
		 {
			 NSArray *array = data[@"location_suggestions"];//location suggestion is an array
			for(NSDictionary *obj in array)
			{
				CityDetails *cityDetail=[[CityDetails alloc]initWithDictionary:obj];
				[cityDetails addObject:cityDetail];
				
			}
			 
		 }
		 callBackToMainVC(cityDetails,errorMsg);
	 }];
	}];
}


#pragma mark-Making URL along with Parameters
+(NSURL *) composeURLWithParameters :(NSString *)citySearch withParameter2:(NSInteger)count {
	NSURLComponents *components=[NSURLComponents componentsWithString:ZOMATO_URL];
	NSURLQueryItem *city=[NSURLQueryItem queryItemWithName:@"q" value:citySearch];
	NSString *limit_data_fetch=[NSString stringWithFormat:@"%ld",count];
	NSURLQueryItem *limit=[NSURLQueryItem queryItemWithName:@"count" value:limit_data_fetch];
	components.queryItems=@[city,limit];
	NSURL *url=components.URL;
	return url;
	
}

@end
