//
// Created by Vadim Degterev on 10.08.15.
// Copyright (c) 2015 908 Inc. All rights reserved.
//


@class SKPaymentTransaction;

typedef void (^ STKProductsBlock)(NSArray* products, NSArray* invalidProductsIdentifier);
typedef void (^ STKPurchaseCompletionBlock)(SKPaymentTransaction* transaction);
typedef void (^ STKRestoreCompletionBlock)(SKPaymentTransaction* transaction);
typedef void (^ STKPurchaseFailureBlock)(NSError* error);

@protocol STKPurchaseServiceDelegate <NSObject>
@optional
- (void)purchaseSucceedForPack: (NSString*)packName withPrice: (NSString*)packPrice;

- (void)purchaseFailed;
@end

//TODO:possibly unused class

@interface STKPurchaseService : NSObject
@property (nonatomic, weak) id <STKPurchaseServiceDelegate> delegate;

- (BOOL)isPurchasedProductWithIdentifier: (NSString*)identifier;

- (void)purchaseProductWithIdentifier: (NSString*)productIdentifier
						   completion: (STKPurchaseCompletionBlock)completion
							  failure: (STKPurchaseFailureBlock)failure;

- (void)requestProductsWithIdentifiers: (NSSet*)identifiers completion: (STKProductsBlock)completion;

- (void)purchaseSucceedForPack: (NSString*)packName withPrice: (NSString*)packPrice;
- (void)purchaseFailed;

@end