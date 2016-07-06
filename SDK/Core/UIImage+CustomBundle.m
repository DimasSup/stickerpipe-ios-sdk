//
//  UIImage+CustomBundle.m
//  MyWorkFramework
//
//  Created by Alexander908 on 6/2/16.
//  Copyright © 2016 Alexander908. All rights reserved.
//

#import "UIImage+CustomBundle.h"

@implementation UIImage (CustomBundle)

+ (UIImage *)imageNamedInCustomBundle:(NSString *)name {
	
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ResBundle" ofType:@"bundle"];
	NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
	return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil]?:[UIImage imageNamed:name];
}


@end
