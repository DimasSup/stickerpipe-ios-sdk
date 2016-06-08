//
//  StickerPipeCustomSmileCell.m
//  Little Pal
//
//  Created by admin on 26.05.16.
//  Copyright © 2016 BrillKids. All rights reserved.
//

#import "StickerPipeCustomSmileCell.h"
#import "SmilesHelper.h"


@interface StickerPipeCustomSmileCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation StickerPipeCustomSmileCell


-(void)reinitializeWithSmile:(NSString*)smile
{
	self.imageView.image = [SmilesHelper animateImageForUniversalImagename:[SmilesHelper codeSmiles][smile]];
}

@end
