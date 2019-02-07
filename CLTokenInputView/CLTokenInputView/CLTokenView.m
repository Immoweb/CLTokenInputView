//
//  CLTokenView.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenView.h"

#import <QuartzCore/QuartzCore.h>

static CGFloat const PADDING_X = 10.0;
static CGFloat const PADDING_Y = 5.0;


@interface CLTokenView ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *removeButton;

@property (copy, nonatomic) NSString *displayText;

@property (strong, nonatomic, nullable) IBInspectable UIColor *tokenBackgroundColor;
@property (strong, nonatomic, nullable) IBInspectable UIColor *tokenTextColor;
@property (strong, nonatomic, nullable) IBInspectable UIColor *tokenBackgroundActiveColor;
@property (strong, nonatomic, nullable) IBInspectable UIColor *tokenTextActiveColor;

@property (strong, nonatomic, nullable) NSLayoutConstraint *maxWidthConstraint;

@end

@implementation CLTokenView

- (instancetype)initWithToken:(CLToken *)token
			   font:(nullable UIFont *)font
tokenBackgroundColor:(UIColor *)tokenBackgroundColor
	 tokenTextColor:(UIColor *)tokenTextColor
tokenBackgroundActiveColor:(UIColor *)tokenBackgroundActiveColor
tokenTextActiveColor:(UIColor *)tokenTextActiveColor;
{
	self = [super initWithFrame:CGRectZero];
	if (self) {
		if (tokenTextColor != nil) {
			self.tokenTextColor = tokenTextColor;
		} else {
			self.tokenTextColor = [UIColor whiteColor];
		}

		if (tokenTextActiveColor != nil) {
			self.tokenTextActiveColor = tokenTextActiveColor;
		} else {
			self.tokenTextActiveColor = [UIColor whiteColor];
		}

		if (tokenBackgroundColor != nil) {
			self.tokenBackgroundColor = tokenBackgroundColor;
		} else {
			self.tokenBackgroundColor = [UIColor colorWithRed:0.24 green:0.42 blue:0.66 alpha:1.0];
		}

		if (tokenBackgroundActiveColor != nil) {
			self.tokenBackgroundActiveColor = tokenBackgroundActiveColor;
		} else {
			self.tokenBackgroundActiveColor = [UIColor colorWithRed:0.14 green:0.32 blue:0.8 alpha:1.0];
		}

		self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
		self.backgroundView.backgroundColor = self.tokenBackgroundColor;
		self.backgroundView.layer.cornerRadius = 4.0;
		self.backgroundView.layer.masksToBounds = YES;
		[self addSubview:self.backgroundView];

		self.label = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_X, PADDING_Y, 0, 0)];
		if (font) {
			self.label.font = font;
		}
		self.label.textColor = self.tokenTextColor;
		self.label.lineBreakMode = NSLineBreakByTruncatingMiddle;
		self.label.backgroundColor = [UIColor clearColor];
		[self addSubview:self.label];

		NSBundle *bundle = [NSBundle bundleForClass:self.class];
		NSString *podBundlePath = [bundle pathForResource:@"CLTokenInputView" ofType:@"bundle"];

		if (podBundlePath) {
			NSBundle *resourcesBundle = [[NSBundle alloc] initWithPath:podBundlePath];

			if (resourcesBundle) {
				bundle = resourcesBundle;
			}
		}

		self.removeButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[self.removeButton setImage:[UIImage imageNamed:@"Close"
											   inBundle:bundle
						  compatibleWithTraitCollection:nil]
						   forState:UIControlStateNormal];
		self.removeButton.tintColor = self.tokenTextColor;
		[self addSubview:self.removeButton];

		[self setUpConstraints];

		self.displayText = token.displayText;
		self.label.text = self.displayText;

		[self.removeButton addTarget:self
							  action:@selector(removeButtonClicked)
					forControlEvents:UIControlEventTouchUpInside];

		// Listen for taps
		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
		[self addGestureRecognizer:tapRecognizer];

		[self setNeedsLayout];

	}
	return self;
}

- (void)setUpConstraints
{
	self.translatesAutoresizingMaskIntoConstraints = NO;
	self.label.translatesAutoresizingMaskIntoConstraints = NO;
	self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
	self.removeButton.translatesAutoresizingMaskIntoConstraints = NO;

	[self addConstraints:[NSLayoutConstraint
						  constraintsWithVisualFormat:@"H:|[background]|"
						  options:0
						  metrics:nil
						  views:@{@"background": self.backgroundView}]];

	[self addConstraints:[NSLayoutConstraint
						  constraintsWithVisualFormat:@"V:|[background]|"
						  options:0
						  metrics:nil
						  views:@{@"background": self.backgroundView}]];

	[self addConstraints:[NSLayoutConstraint
						  constraintsWithVisualFormat:@"H:|-(padding)-[label][button(buttonWidth)]|"
						  options:0
						  metrics:@{@"padding": @(PADDING_X), @"buttonWidth": @((PADDING_X * 2) + 10)}
						  views:@{@"label": self.label, @"button": self.removeButton}]];

	[self addConstraints:[NSLayoutConstraint
						  constraintsWithVisualFormat:@"V:|-(padding)-[label]-(padding)-|"
						  options:0
						  metrics:@{@"padding": @(PADDING_Y)}
						  views:@{@"label": self.label}]];

	[self addConstraint:[NSLayoutConstraint
						 constraintWithItem:self.removeButton
						 attribute:NSLayoutAttributeCenterY
						 relatedBy:NSLayoutRelationEqual
						 toItem:self
						 attribute:NSLayoutAttributeCenterY
						 multiplier:1
						 constant:0]];

	self.maxWidthConstraint = [NSLayoutConstraint
							   constraintWithItem:self
							   attribute:NSLayoutAttributeWidth
							   relatedBy:NSLayoutRelationLessThanOrEqual
							   toItem:nil
							   attribute:NSLayoutAttributeNotAnAttribute
							   multiplier:1
							   constant:100];

	[self addConstraint:self.maxWidthConstraint];
}

- (void)setMaxWidth:(CGFloat)maxWidth {
	_maxWidth = maxWidth;
	self.maxWidthConstraint.constant = _maxWidth;
}


#pragma mark - Taps

- (void)removeButtonClicked
{
	[self.delegate tokenViewDidRequestDelete:self replaceWithText:nil];
}

-(void)handleTapGestureRecognizer:(id)sender
{
	[self.delegate tokenViewDidRequestSelection:self];
}


#pragma mark - Selection

- (void)setSelected:(BOOL)selected
{
	[self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	if (_selected == selected) {
		return;
	}
	_selected = selected;

	if (selected && !self.isFirstResponder) {
		[self becomeFirstResponder];
	} else if (!selected && self.isFirstResponder) {
		[self resignFirstResponder];
	}

	if (selected) {
		self.backgroundView.backgroundColor = self.tokenBackgroundActiveColor;
		self.label.textColor = self.tokenTextActiveColor;
	} else {
		self.backgroundView.backgroundColor = self.tokenBackgroundColor;
		self.label.textColor = self.tokenTextColor;
	}

	self.removeButton.tintColor = self.label.textColor;
}

- (void)blink {
	NSTimeInterval duration = 0.8;
	[UIView animateKeyframesWithDuration:duration
								   delay:0
								 options:UIViewKeyframeAnimationOptionBeginFromCurrentState
							  animations:^{
								  CGFloat frames = 4;

								  for (CGFloat frame = 0; frame < frames; frame++) {
									  [UIView addKeyframeWithRelativeStartTime:frame/frames relativeDuration:1.0/frames animations:^{
										  if ((NSInteger)frame % 2 == 0) {
											  self.alpha = 0;
										  } else {
											  self.alpha = 1;
										  }
									  }];
								  }
							  }
							  completion:nil];
}


#pragma mark - UIKeyInput protocol

- (BOOL)hasText
{
	return YES;
}

- (void)insertText:(NSString *)text
{
	[self.delegate tokenViewDidRequestDelete:self replaceWithText:text];
}

- (void)deleteBackward
{
	[self.delegate tokenViewDidRequestDelete:self replaceWithText:nil];
}


#pragma mark - UITextInputTraits protocol (inherited from UIKeyInput protocol)

// Since a token isn't really meant to be "corrected" once created, disable autocorrect on it
// See: https://github.com/clusterinc/CLTokenInputView/issues/2
- (UITextAutocorrectionType)autocorrectionType
{
	return UITextAutocorrectionTypeNo;
}


#pragma mark - First Responder (needed to capture keyboard)

-(BOOL)canBecomeFirstResponder
{
	return YES;
}


-(BOOL)resignFirstResponder
{
	BOOL didResignFirstResponder = [super resignFirstResponder];
	[self setSelected:NO animated:NO];
	return didResignFirstResponder;
}

-(BOOL)becomeFirstResponder
{
	BOOL didBecomeFirstResponder = [super becomeFirstResponder];
	[self setSelected:YES animated:NO];
	return didBecomeFirstResponder;
}


@end

