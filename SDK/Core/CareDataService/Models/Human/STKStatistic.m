#import "STKStatistic.h"

@interface STKStatistic ()

// Private interface goes here.

@end

@implementation STKStatistic

// Custom logic goes here.

- (NSDictionary*)dictionary {
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];

	if (self.category) {
		dictionary[STKStatisticAttributes.category] = self.category;
	}
	if (self.time) {
		dictionary[STKStatisticAttributes.time] = self.time;
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

	NSDictionary* resultDictionary = [NSDictionary dictionaryWithDictionary: dictionary];

	return resultDictionary;
}

@end
