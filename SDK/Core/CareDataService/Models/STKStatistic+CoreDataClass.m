//
//  STKStatistic+CoreDataClass.m
//  
//
//  Created by vlad on 11/24/16.
//
//

#import "STKStatistic+CoreDataClass.h"

const struct STKStatisticAttributes STKStatisticAttributes = {
    .action = @"action",
    .category = @"category",
    .label = @"label",
    .time = @"time",
    .value = @"value",
};

@implementation STKStatistic

- (NSDictionary*)dictionary {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    if (self.category) {
        dictionary[STKStatisticAttributes.category] = self.category;
    }
    if (self.action) {
        dictionary[STKStatisticAttributes.action] = self.action;
    }
    if (self.label) {
        dictionary[STKStatisticAttributes.label] = self.label;
    }
    if (self.value) {
        dictionary[STKStatisticAttributes.value] = self.value;
    }
    
    return dictionary;
}

@end
