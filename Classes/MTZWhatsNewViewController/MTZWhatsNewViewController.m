//
//  MTZWhatsNewViewController.m
//  What's New
//
//  Created by Matt Zanchelli on 5/17/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZWhatsNewViewController.h"

#import "MTZCollectionView.h"
#import "MTZWhatsNewFeatureCollectionViewCell.h"

#import "SAMGradientView.h"

#import "NSLayoutConstraint+Common.h"

@interface MTZWhatsNewViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

///	An ordered list of the versions from newest to oldest.
@property (strong, nonatomic) NSArray *orderedKeys;

///	The collection view to display all the new features.
@property (strong, nonatomic) MTZCollectionView *collectionView;

///	The gradient presented as the background.
@property (strong, nonatomic) SAMGradientView *backgroundGradientView;

@end

@implementation MTZWhatsNewViewController

- (id)init
{
	self = [super init];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	// Default modal transition and presentation styles.
	self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	self.modalPresentationStyle = UIModalPresentationFormSheet;
	
	// Background.
	self.backgroundGradientView = [[SAMGradientView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.backgroundGradientView];
	self.backgroundGradientView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraints:[NSLayoutConstraint constraintsToFillToSuperview:self.backgroundGradientView]];
	self.backgroundGradientView.gradientColors = @[[UIColor clearColor], [UIColor clearColor]];
	self.backgroundGradientView.gradientLocations = @[@0.0, @1.0];
	
	// Feature collection view.
	UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
	flowLayout.minimumLineSpacing = 2;
	flowLayout.minimumInteritemSpacing = 0;
	if ( [self shouldUseGridLayout] ) {
		flowLayout.itemSize = CGSizeMake(270, 187);
	} else {
		flowLayout.itemSize = CGSizeMake(320, 108);
	}
	flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
	flowLayout.headerReferenceSize = flowLayout.footerReferenceSize = CGSizeZero;
	
	self.collectionView = [[MTZCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
	[self.view addSubview:self.collectionView];
	self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraints:[NSLayoutConstraint constraintsToFillToSuperview:self.collectionView]];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"whatsnew"];
	[self.collectionView registerClass:[MTZWhatsNewFeatureCollectionViewCell class] forCellWithReuseIdentifier:@"feature"];
	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 50, 0);
	self.collectionView.contentInset = edgeInsets;
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.scrollIndicatorInsets = edgeInsets;
	self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	
	// Get Started.
	UIView *buttonBackground = [[UIView alloc] init];
	[self.view addSubview:buttonBackground];
	buttonBackground.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraints:[NSLayoutConstraint constraintsToStretchHorizontallyToSuperview:buttonBackground]];
	[self.view addConstraints:[NSLayoutConstraint constraintsToStickView:buttonBackground toEdges:UIRectEdgeBottom]];
	[buttonBackground addConstraint:[NSLayoutConstraint constraintWithItem:buttonBackground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:50.0f]];
	buttonBackground.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
	
	UIButton *button = [[UIButton alloc] init];
	[self.view addSubview:button];
	button.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraints:[NSLayoutConstraint constraintsToStretchHorizontallyToSuperview:button]];
	[self.view addConstraints:[NSLayoutConstraint constraintsToStickView:button toEdges:UIRectEdgeBottom]];
	[button addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:50.0f]];
	[button setTitle:NSLocalizedString(@"Get Started", nil) forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f] forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(didTapContinueButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.collectionView flashScrollIndicators];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}


#pragma mark - Actions

- (IBAction)didTapContinueButton:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Properties

- (void)setFeatures:(NSDictionary *)features
{
	_features = [features copy];
	_orderedKeys = [[_features allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [obj2 compare:obj1 options:NSNumericSearch];
	}];
	
	// Reload the collection view's data.
	[self.collectionView reloadData];
}

- (void)setTopColor:(UIColor *)topColor
{
	_topColor = [topColor copy];
	self.backgroundGradientView.gradientColors = @[_topColor, self.backgroundGradientView.gradientColors[1]];
}

- (void)setBottomColor:(UIColor *)bottomColor
{
	_bottomColor = [bottomColor copy];
	self.backgroundGradientView.gradientColors = @[self.backgroundGradientView.gradientColors[0], _bottomColor];
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	// "What's New"
	if ( section == 0 ) {
		if ( [self shouldUseGridLayout] ) {
			return CGSizeMake(self.view.bounds.size.width, 115);
		} else {
			return CGSizeMake(self.view.bounds.size.width, 70);
		}
	}
	
	// No header for section.
	return CGSizeZero;
}


#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [self.features count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	NSString *key = self.orderedKeys[section];
	return [self.features[key] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
		   viewForSupplementaryElementOfKind:(NSString *)kind
								 atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"whatsnew" forIndexPath:indexPath];
	
	// Create label for "What's New" title.
	UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
	[view addSubview:label];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	[view addConstraints:[NSLayoutConstraint constraintsToStretchHorizontallyToSuperview:label]];
	label.text = NSLocalizedString(@"What’s New", nil);
	label.textColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentCenter;
	
	// Larger font and divider.
	if ( [self shouldUseGridLayout] ) {
		label.font = [UIFont fontWithName:@"HelveticaNeue-Ultralight" size:62];
		label.frame = CGRectMake(0, 0, view.bounds.size.width, 103);
		
		// Divider
		UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(122, 103, 296, 0.5)];
		divider.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
		[view addSubview:divider];
	} else {
		label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:30];
	}
	
	return view;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	MTZWhatsNewFeatureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feature" forIndexPath:indexPath];
	
	NSDictionary *feature = self.features[self.orderedKeys[indexPath.section]][indexPath.row];
	
	cell.title = feature[@"Title"];
	cell.detail = feature[@"Detail"];
	NSString *iconName = feature[@"Icon"];
	if ( iconName ) {
		cell.icon = [UIImage imageNamed:iconName];
	}
	
	cell.layoutStyle = [self shouldUseGridLayout] ? MTZWhatsNewFeatureCollectionViewCellLayoutStyleGrid : MTZWhatsNewFeatureCollectionViewCellLayoutStyleList;
	
	return cell;
}


#pragma mark - Helpers

- (BOOL)shouldUseGridLayout
{
	// iPhone width = 320
	// iPad's UIModalPresentationFormSheet width = 540
	return self.view.frame.size.width >= 512;
}


@end
