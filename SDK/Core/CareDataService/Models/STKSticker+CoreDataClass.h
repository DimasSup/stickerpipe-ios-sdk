//
//  STKSticker+CoreDataClass.h
//  
//
//  Created by vlad on 11/24/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKStickerPack;
@class STKSticker;

NS_ASSUME_NONNULL_BEGIN

typedef void(^STKStickerObjectBlock)(STKSticker* stickerObject, BOOL recent);

@interface STKSticker : NSManagedObject

+ (instancetype)stickerWithDictionary: (NSDictionary*)dictionary;
- (void)loadStickerImage;

@end

NS_ASSUME_NONNULL_END

#import "STKSticker+CoreDataProperties.h"
