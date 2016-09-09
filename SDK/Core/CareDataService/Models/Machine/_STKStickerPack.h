// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to STKStickerPack.h instead.

#import <CoreData/CoreData.h>

extern const struct STKStickerPackAttributes {
	__unsafe_unretained NSString* artist;
	__unsafe_unretained NSString* bannerUrl;
	__unsafe_unretained NSString* disabled;
	__unsafe_unretained NSString* isNew;
	__unsafe_unretained NSString* order;
	__unsafe_unretained NSString* packDescription;
	__unsafe_unretained NSString* packID;
	__unsafe_unretained NSString* packName;
	__unsafe_unretained NSString* packTitle;
	__unsafe_unretained NSString* price;
	__unsafe_unretained NSString* pricePoint;
	__unsafe_unretained NSString* productID;
} STKStickerPackAttributes;

extern const struct STKStickerPackRelationships {
	__unsafe_unretained NSString* stickers;
} STKStickerPackRelationships;

@class STKSticker;

@interface STKStickerPackID : NSManagedObjectID {
}
@end

@interface _STKStickerPack : NSManagedObject {
}
+ (id)insertInManagedObjectContext: (NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext: (NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) STKStickerPackID* objectID;

@property (nonatomic, strong) NSString* artist;

//- (BOOL)validateArtist:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* bannerUrl;

//- (BOOL)validateBannerUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* disabled;

@property (atomic) BOOL disabledValue;
- (BOOL)disabledValue;
- (void)setDisabledValue: (BOOL)value_;

//- (BOOL)validateDisabled:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* isNew;

@property (atomic) BOOL isNewValue;
- (BOOL)isNewValue;
- (void)setIsNewValue: (BOOL)value_;

//- (BOOL)validateIsNew:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* order;

@property (atomic) int32_t orderValue;
- (int32_t)orderValue;
- (void)setOrderValue: (int32_t)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* packDescription;

//- (BOOL)validatePackDescription:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* packID;

@property (atomic) int64_t packIDValue;
- (int64_t)packIDValue;
- (void)setPackIDValue: (int64_t)value_;

//- (BOOL)validatePackID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* packName;

//- (BOOL)validatePackName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* packTitle;

//- (BOOL)validatePackTitle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* pricePoint;

@property (nonatomic, strong) NSNumber* price;

@property (atomic) float priceValue;
- (float)priceValue;
- (void)setPriceValue: (float)value_;

//- (BOOL)validatePrice:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* productID;

//- (BOOL)validateProductID:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSOrderedSet* stickers;

- (NSMutableOrderedSet*)stickersSet;

@end
