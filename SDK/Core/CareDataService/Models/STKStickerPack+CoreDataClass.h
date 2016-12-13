//
//  STKStickerPack+CoreDataClass.h
//  
//
//  Created by vlad on 11/24/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STKSticker;

NS_ASSUME_NONNULL_BEGIN

@interface STKStickerPack : NSManagedObject

+ (instancetype)stickerPackWithDict: (NSDictionary*)dict;

+ (NSArray*)serializeStickerPacks: (NSArray<NSDictionary*>*)stickerPacks;

- (void)fillWithDict:(NSDictionary* )dict;

@end

NS_ASSUME_NONNULL_END

#import "STKStickerPack+CoreDataProperties.h"
