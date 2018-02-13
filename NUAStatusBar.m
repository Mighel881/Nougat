#import "NUANotificationShadeController.h"
#import "NUAStatusBar.h"
#import "NUAPreferenceManager.h"
#import "Macros.h"
#import <SpringBoard/SpringBoard.h>

@implementation NUAStatusBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _resourceBundle = [NSBundle bundleWithPath:@"/var/mobile/Library/Nougat-Resources.bundle"];

        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width / 2, frame.size.height)];
        self.dateLabel.font = [UIFont systemFontOfSize:14];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.dateLabel];

        _dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"h:mm a - EEE, MMM d";

        NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
        self.dateLabel.text = dateString;

        [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];

        [self loadRight];
    }

    return self;
}

- (void)loadRight {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(kScreenWidth / 1.3, 10, 20, 20);
    UIImage *settingsCog = [UIImage imageNamed:@"settings" inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    [settingsButton setImage:settingsCog forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingsButton];

    _toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleButton.frame = CGRectMake(kScreenWidth / 1.1, 10, 20, 20);
    UIImage *arrow = [UIImage imageNamed:@"showMain" inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    [self.toggleButton setImage:arrow forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(toggleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleButton];

}

- (void)settingsButtonTapped:(UIButton *)sender {
    [[NUANotificationShadeController defaultNotifcationShade] dismissDrawer:YES];
    [(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.Preferences" suspended:NO];
}

- (void)toggleButtonTapped:(UIButton *)sender {
    if ([[NUANotificationShadeController defaultNotifcationShade] mainTogglesVisible]) {
        [[NUANotificationShadeController defaultNotifcationShade] showQuickToggles];
    } else {
        [[NUANotificationShadeController defaultNotifcationShade] showMainToggles];
    }
}

- (void)updateToggle:(BOOL)toggled {
    NSString *arrowName = toggled ? @"dismissMain" : @"showMain";
    UIImage *arrow = [UIImage imageNamed:arrowName inBundle:self.resourceBundle compatibleWithTraitCollection:nil];
    [self.toggleButton setImage:arrow forState:UIControlStateNormal];
}

- (void)updateTime:(NSTimer *)timer {
    NSString *dateString = [self.dateFormatter stringFromDate:[NSDate date]];
    self.dateLabel.text = dateString;
}

@end
