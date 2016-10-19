#import "STKStatistic.h"

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
