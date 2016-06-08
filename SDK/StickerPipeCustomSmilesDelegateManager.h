//
//  StickerPipeCustomSmilesDelegateManager.h
//  Little Pal
//
//  Created by admin on 26.05.16.
//  Copyright © 2016 BrillKids. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStickerPipeCustomSmileCell @"sticker_pipe_custom_smile_cell"

@interface StickerPipeCustomSmilesDelegateManager : NSObject<UICollectionViewDelegate,UICollectionViewDataSource>



@property (nonatomic, copy) void(^didSelectCustomSmile)(NSString* smile,NSIndexPath* indexPath);

-(void)setAllSmiles:(NSArray*)smiles;

@end
