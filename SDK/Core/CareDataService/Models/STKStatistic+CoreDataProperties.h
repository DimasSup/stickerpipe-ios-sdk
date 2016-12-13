//
//  STKStatistic+CoreDataProperties.h
//  
//
//  Created by vlad on 11/24/16.
//
//

#import "STKStatistic+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface STKStatistic (CoreDataProperties)

+ (NSFetchRequest<STKStatistic *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *action;
@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, copy) NSString *label;
@property (nullable, nonatomic, copy) NSNumber *time;
@property (nullable, nonatomic, copy) NSNumber *value;

@end

NS_ASSUME_NONNULL_END
