//
//  STKStatistic+CoreDataProperties.m
//  
//
//  Created by vlad on 11/24/16.
//
//

#import "STKStatistic+CoreDataProperties.h"

@implementation STKStatistic (CoreDataProperties)

+ (NSFetchRequest<STKStatistic *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"STKStatistic"];
}

@dynamic action;
@dynamic category;
@dynamic label;
@dynamic time;
@dynamic value;

@end
