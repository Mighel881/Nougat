#import "NUAMediaTableViewCell.h"
#import "Media/NUAMediaControlsView.h"
#import "Media/NUAMediaHeaderView.h"
#import "UIColor+Accent.h"
#import "UIImage+Average.h"
#import <MediaRemote/MediaRemote.h>
#import <SpringBoardServices/SpringBoardServices+Private.h>
#import <UIKit/UIImage+Private.h>

@interface NUAMediaTableViewCell ()
@property (strong, nonatomic) UIImageView *artworkView;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
@property (strong, nonatomic) NUAMediaControlsView *controlsView;
@property (strong, nonatomic) NUAMediaHeaderView *headerView;

@property (strong, nonatomic) NSLayoutConstraint *controlsViewConstraint;

@end

@implementation NUAMediaTableViewCell

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Register as delegate
        _nowPlayingController = [[NSClassFromString(@"MPUNowPlayingController") alloc] init];
        self.nowPlayingController.delegate = self;

        // Register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMedia) name:(__bridge_transfer NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
        [self.nowPlayingController _registerForNotifications];

        // Create views
        [self setupViews];

        // Update
        [self updateMedia];
    }

    return self;
}

- (void)setupViews {
    [self _createArtworkView];
    [self _createGradientView];
    [self _createHeaderView];
    [self _createControlsView];

    // Constraints
    [self setupConstraints];
}

- (void)setupConstraints {
    // Constrain the bad boys
    [self.artworkView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.artworkView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.artworkView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.artworkView.widthAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;

    [self.headerView.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:6.0].active = YES;
    [self.headerView.leadingAnchor constraintEqualToAnchor:self.glyphView.leadingAnchor].active = YES;
    [self.headerView.trailingAnchor constraintEqualToAnchor:self.artworkView.leadingAnchor constant:-10.0].active = YES;

    self.controlsViewConstraint = [self.controlsView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:10.0];
    self.controlsViewConstraint.active = YES;
    [self.controlsView.trailingAnchor constraintEqualToAnchor:self.artworkView.leadingAnchor].active = YES;

    // Additional constraints
    [self.headerLabel.trailingAnchor constraintEqualToAnchor:self.artworkView.leadingAnchor constant:-10.0].active = YES;

    [self.contentView bringSubviewToFront:self.expandButton];
    [self.expandButton.topAnchor constraintEqualToAnchor:self.headerLabel.topAnchor].active = YES;
    [self.expandButton.leadingAnchor constraintEqualToAnchor:self.headerLabel.trailingAnchor constant:5.0].active = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // Set bounds
    self.gradientLayer.frame = self.artworkView.bounds;
}

#pragma mark - Media views

- (void)_createArtworkView {
    self.artworkView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.artworkView.contentMode = UIViewContentModeScaleAspectFit;
    self.artworkView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.artworkView];
}

- (void)_createGradientView {
    UIView *gradientView = [[UIView alloc] initWithFrame:self.bounds];
    [self.artworkView addSubview:gradientView];

    [gradientView.topAnchor constraintEqualToAnchor:self.artworkView.topAnchor].active = YES;
    [gradientView.bottomAnchor constraintEqualToAnchor:self.artworkView.bottomAnchor].active = YES;
    [gradientView.leadingAnchor constraintEqualToAnchor:self.artworkView.leadingAnchor].active = YES;
    [gradientView.trailingAnchor constraintEqualToAnchor:self.artworkView.trailingAnchor].active = YES;

    // Create layer
    self.gradientLayer = [CAGradientLayer layer];
    UIColor *baseColor = [UIColor whiteColor];
    self.gradientLayer.colors = @[(id)baseColor.CGColor, (id)[baseColor colorWithAlphaComponent:0.85].CGColor, (id)[baseColor colorWithAlphaComponent:0.0].CGColor];
    self.gradientLayer.locations = @[@(0.0), @(0.5), @(1.0)];
    self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    self.gradientLayer.frame = self.artworkView.bounds;
    [gradientView.layer addSublayer:self.gradientLayer];
}

- (void)_updateBackgroundGradientWithColor:(UIColor *)color {
    self.backgroundColor = color;
    self.gradientLayer.colors = @[(id)color.CGColor, (id)[color colorWithAlphaComponent:0.85].CGColor, (id)[color colorWithAlphaComponent:0.0].CGColor];

    // Update frame for good measure
    self.gradientLayer.frame = self.artworkView.bounds;
}

- (void)_createHeaderView {
    self.headerView = [[NUAMediaHeaderView alloc] initWithFrame:CGRectZero];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.headerView];
}

- (void)_createControlsView {
    self.controlsView = [[NUAMediaControlsView alloc] initWithFrame:CGRectZero];
    self.controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.controlsView];
}

#pragma mark - Properties

- (void)setExpanded:(BOOL)expanded {
    [super setExpanded:expanded];

    self.headerView.expanded = expanded;
    self.controlsView.expanded = expanded;

    self.controlsViewConstraint.constant = expanded ? 50.0 : 10.0;
}

- (BOOL)isPlaying {
    return self.nowPlayingController.isPlaying;
}

- (void)setNowPlayingArtwork:(UIImage *)nowPlayingArtwork {    
    _nowPlayingArtwork = nowPlayingArtwork;

    if (!nowPlayingArtwork) {
        return;
    }

    self.artworkView.image = nowPlayingArtwork;
    [self _updateTintsForArtwork:nowPlayingArtwork];
}

- (void)setNowPlayingAppDisplayID:(NSString *)nowPlayingAppDisplayID {
    _nowPlayingAppDisplayID = nowPlayingAppDisplayID;

    // Update imageview
    [self _updateHeaderLabelText];
    UIImage *appIcon = [UIImage _applicationIconImageForBundleIdentifier:nowPlayingAppDisplayID format:0 scale:[UIScreen mainScreen].scale];
    self.glyphView.image = appIcon;
}

- (void)setMetadata:(MPUNowPlayingMetadata *)metadata {
    _metadata = metadata;

    // Parse and pass to header
    self.headerView.artist = metadata.artist;
    self.headerView.song = metadata.title;

    // Update label
    [self _updateHeaderLabelText];
}

- (void)_updateTintsForArtwork:(UIImage *)artwork {
    UIColor *averageColor = artwork.averageColor;
    [self _updateBackgroundGradientWithColor:averageColor];

    // Set tint color
    UIColor *accentColor = averageColor.accentColor;
    self.headerLabel.textColor = accentColor;
    self.headerView.tintColor = accentColor;
    self.controlsView.tintColor = accentColor;

    // Update button
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *baseImage = [UIImage imageNamed:@"arrow-dark" inBundle:bundle];

    // Tint and set
    UIImage *tintedImage = [baseImage _flatImageWithColor:accentColor];
    [self.expandButton setImage:tintedImage forState:UIControlStateNormal];
}

#pragma mark - Info label

- (void)_updateHeaderLabelText {
    // Construct strings
    NSString *displayID = self.nowPlayingAppDisplayID ?: @"com.apple.Music";
    NSString *appDisplayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(displayID);
    NSString *baseText = [NSString stringWithFormat:@"%@ • %@", appDisplayName, self.metadata.album];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:baseText];
    NSRange boldedRange = NSMakeRange(0, appDisplayName.length);
    UIFont *boldFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    // Add attributes
    [attributedString beginEditing];
    [attributedString addAttribute:NSFontAttributeName value:boldFont range:boldedRange];
    [attributedString endEditing];

    self.headerLabel.attributedText = [attributedString copy];
}

#pragma mark - Notifications

- (void)updateMedia {
    // Pass to view
    self.nowPlayingArtwork = self.nowPlayingController.currentNowPlayingArtwork;
    self.metadata = self.nowPlayingController.currentNowPlayingMetadata;
    self.nowPlayingAppDisplayID = self.nowPlayingController.nowPlayingAppDisplayID;
}

#pragma mark - MPUNowPlayingDelegate

- (void)nowPlayingController:(MPUNowPlayingController *)controller nowPlayingInfoDidChange:(NSDictionary *)nowPlayingInfo {
    // Parse and pass on
    self.nowPlayingArtwork = controller.currentNowPlayingArtwork;
    self.metadata = controller.currentNowPlayingMetadata;
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller playbackStateDidChange:(BOOL)isPlaying {
    // Pass to controls
    self.controlsView.playing = isPlaying;
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller nowPlayingApplicationDidChange:(NSString *)nowPlayingAppDisplayID {
    // Pass to header
    self.nowPlayingAppDisplayID = nowPlayingAppDisplayID;
}

- (void)nowPlayingControllerDidBeginListeningForNotifications:(MPUNowPlayingController *)controller {

}

- (void)nowPlayingControllerDidStopListeningForNotifications:(MPUNowPlayingController *)controller {

}

- (void)nowPlayingController:(MPUNowPlayingController *)controller elapsedTimeDidChange:(double)elapsedTime {

}

@end