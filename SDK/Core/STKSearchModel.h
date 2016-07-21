//
//  SearchModel.h
//  StickerPipe
//
//  Created by Alexander908 on 7/14/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKSearchModel : NSObject

@property (nonatomic, strong) NSString *q;
@property (nonatomic, strong) NSString *topIfEmpty;
@property (nonatomic, strong) NSString *wholeWord;
@property (nonatomic, strong) NSString *limit;

@property (nonatomic, assign) BOOL isSuggest;

@end
