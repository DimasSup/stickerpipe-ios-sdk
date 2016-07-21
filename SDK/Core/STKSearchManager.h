//
//  SearchManager.h
//  StickerPipe
//
//  Created by Alexander908 on 7/14/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKApiAbstractService.h"

@class STKSearchModel;

@interface STKSearchManager : STKApiAbstractService

- (void)searchStickersWithSearchModel:(STKSearchModel *)searchModel completion:(void(^)(NSArray *stickers))completion;

@end
