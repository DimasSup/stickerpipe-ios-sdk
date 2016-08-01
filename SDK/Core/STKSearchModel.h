//
//  SearchModel.h
//  StickerPipe
//
//  Created by Alexander908 on 7/14/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKSearchModel : NSObject

@property (nonatomic) NSString* q;
@property (nonatomic) NSString* topIfEmpty;
@property (nonatomic) NSString* wholeWord;
@property (nonatomic) NSString* limit;

@property (nonatomic) BOOL isSuggest;

@end
