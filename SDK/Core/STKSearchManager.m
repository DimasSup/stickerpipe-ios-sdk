//
//  SearchManager.m
//  StickerPipe
//
//  Created by Alexander908 on 7/14/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKSearchManager.h"
#import <AFNetworking/AFNetworking.h>

#import "STKSearchModel.h"

static NSString *const searchURL = @"search";

@implementation STKSearchManager

- (void)searchStickersWithSearchModel:(STKSearchModel *)searchModel completion:(void(^)(NSArray *stickers))completion {

    if (searchModel.isSuggest) {
        searchModel.topIfEmpty = @"0";
        searchModel.wholeWord = @"1";
    } else {
        searchModel.topIfEmpty = @"1";
        searchModel.wholeWord = @"0";
    }
    
    searchModel.limit = @"20";
    
    NSDictionary *params = @{
                             @"q" : searchModel.q,
                             @"top_if_empty" : searchModel.topIfEmpty,
                             @"whole_word" : searchModel.wholeWord,
                             @"limit" : searchModel.limit
                             };
    
    
    [self.getSessionManager GET:searchURL parameters: params
                        success:^(NSURLSessionDataTask *task, id responseObject) {
                            NSLog(@"responseObject = %@", responseObject);
                            
                            if (completion) {
                                completion(responseObject[@"data"]);
                            }
                        }
                        failure:^(NSURLSessionDataTask *task, NSError *error) {
                            if (completion) {
                                completion(nil);
                            }
                        }];
}

@end
