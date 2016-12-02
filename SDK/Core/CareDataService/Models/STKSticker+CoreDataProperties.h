//
//  STKSticker+CoreDataProperties.h
//  
//
//  Created by vlad on 11/24/16.
//
//

#import "STKSticker+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface STKSticker (CoreDataProperties)

+ (NSFetchRequest<STKSticker *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *packName;
@property (nullable, nonatomic, copy) NSNumber *stickerID;
@property (nullable, nonatomic, copy) NSString *stickerMessage;
@property (nullable, nonatomic, copy) NSString *stickerName;
@property (nullable, nonatomic, copy) NSString *stickerURL;
@property (nullable, nonatomic, copy) NSNumber *usedCount;
@property (nullable, nonatomic, copy) NSNumber *order;
@property (nullable, nonatomic, copy) NSDate *usedDate;
@property (nullable, nonatomic, retain) STKStickerPack *stickerPack;

@end

NS_ASSUME_NONNULL_END
