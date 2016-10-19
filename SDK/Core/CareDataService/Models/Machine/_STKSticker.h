// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STKSticker.h instead.

#import <CoreData/CoreData.h>

extern const struct STKStickerAttributes {
	__unsafe_unretained NSString* stickerID;
	__unsafe_unretained NSString* stickerMessage;
	__unsafe_unretained NSString* stickerName;
	__unsafe_unretained NSString* usedCount;
	__unsafe_unretained NSString* usedDate;
	__unsafe_unretained NSString* packName;


} STKStickerAttributes;

extern const struct STKStickerRelationships {
	__unsafe_unretained NSString* stickerPack;
} STKStickerRelationships;

@class STKStickerPack;

@interface STKStickerID : NSManagedObjectID {
}
@end

@interface _STKSticker : NSManagedObject {
}
+ (id)insertInManagedObjectContext: (NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext: (NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) STKStickerID* objectID;

@property (nonatomic, strong) NSNumber* stickerID;

@property (atomic) int64_t stickerIDValue;
- (int64_t)stickerIDValue;
- (void)setStickerIDValue: (int64_t)value_;

//- (BOOL)validateStickerID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* stickerMessage;

//- (BOOL)validateStickerMessage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* stickerName;

//- (BOOL)validateStickerName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* usedCount;

//- (BOOL)validateUsedCount:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) STKStickerPack* stickerPack;

@property (nonatomic, strong) NSDate* usedDate;

@property (nonatomic, strong) NSString* packName;

//- (BOOL)validateStickerPack:(id*)value_ error:(NSError**)error_;

@end
