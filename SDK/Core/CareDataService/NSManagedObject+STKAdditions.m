//
//  NSManagedObject+STKAdditions.m
//  StickerFactory
//
//  Created by Vadim Degterev on 01.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "NSManagedObject+STKAdditions.h"
#import "STKUtility.h"

@implementation NSManagedObject (STKAdditions)

+ (NSArray*)stk_findWithPredicate: (NSPredicate*)predicate
				  sortDescriptors: (NSArray*)sortDescriptors
					   fetchLimit: (NSUInteger)fetchLimit
						  context: (NSManagedObjectContext*)context {

	NSFetchRequest* request = [self stk_fetchRequestWithContext: context];
	request.sortDescriptors = sortDescriptors;
	request.predicate = predicate;
	request.fetchLimit = fetchLimit;

	__block NSArray* objects = nil;

	[context performBlockAndWait: ^ {
		NSError* error = nil;

		objects = [context executeFetchRequest: request error: &error];

		if (error) {
			STKLog(@"Coredata error: %@", error.localizedDescription);
		}
	}];

	return objects;
}

+ (NSArray*)stk_findAllInContext: (NSManagedObjectContext*)context {
	NSFetchRequest* request = [self stk_fetchRequestWithContext: context];

	__block NSArray* objects = nil;

	[context performBlockAndWait: ^ {
		NSError* error = nil;

		objects = [context executeFetchRequest: request error: &error];
		if (error) {
			STKLog(@"Coredata error: %@", error.localizedDescription);
		}
	}];

	return objects;
}

+ (NSFetchRequest*)stk_fetchRequestWithContext: (NSManagedObjectContext*)context {
	if (context == nil) {
		STKLog(@"Context is nil");

		return nil;
	}

	NSFetchRequest* request = [NSFetchRequest new];
	request.entity = [NSEntityDescription entityForName: [self stk_entityName] inManagedObjectContext: context];
	return request;
}

+ (NSString*)stk_entityName {
	return [NSStringFromClass(self) componentsSeparatedByString: @"."].lastObject;
}


#pragma mark - Unique

+ (instancetype)stk_objectWithUniqueAttribute: (NSString*)attribute
										value: (id)value
									  context: (NSManagedObjectContext*)context {
	__block id object = nil;
	[context performBlockAndWait: ^ {
		if (value) {
			NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName: [self stk_entityName]];
			NSPredicate* predicate = [NSPredicate predicateWithFormat: @"%K == %@", attribute, value];
			[request setPredicate: predicate];
			NSError* error = nil;
			object = [[context executeFetchRequest: request error: &error] firstObject];
			if (error) {
				STKLog(@"Coredata unique fetching error: %@", error.localizedDescription);
			}
		}

		if (!object) {
			object = [NSEntityDescription insertNewObjectForEntityForName: NSStringFromClass([self class])
												   inManagedObjectContext: context];
		}
	}];

	return object;
}

@end
