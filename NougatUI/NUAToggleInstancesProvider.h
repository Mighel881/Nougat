#import <NougatServices/NougatServices.h>
#import "NUAFlipswitchToggle.h"

@interface NUAToggleInstancesProvider : NSObject
@property (copy, readonly, nonatomic) NSArray<NUAFlipswitchToggle *> *toggleInstances;
@property (strong, readonly, nonatomic) NUAPreferenceManager *notificationShadePreferences;

- (instancetype)initWithPreferences:(NUAPreferenceManager *)preferences;

@end