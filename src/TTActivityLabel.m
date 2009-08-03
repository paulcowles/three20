#import "Three20/TTActivityLabel.h"
#import "Three20/TTView.h"
#import "Three20/TTDefaultStyleSheet.h"
#import "Three20/TTButton.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static CGFloat kMargin = 10;
static CGFloat kPadding = 15;
static CGFloat kBannerPadding = 8;
static CGFloat kSpacing = 6;
static CGFloat kProgressMargin = 6;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTActivityLabel

@synthesize style = _style, progress = _progress, smoothesProgress = _smoothesProgress;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style text:(NSString*)text {
  if (self = [super initWithFrame:frame]) {
    _style = style;
    _progress = 0;
    _smoothesProgress = NO;
    _smoothTimer =nil;
    _progressView = nil;
    
    _bezelView = [[TTView alloc] init];
    if (_style == TTActivityLabelStyleBlackBezel) {
      _bezelView.backgroundColor = [UIColor clearColor];
      _bezelView.style = TTSTYLE(blackBezel);
      self.backgroundColor = [UIColor clearColor];
    } else if (_style == TTActivityLabelStyleWhiteBezel) {
      _bezelView.backgroundColor = [UIColor clearColor];
      _bezelView.style = TTSTYLE(whiteBezel);
      self.backgroundColor = [UIColor clearColor];
    } else if (_style == TTActivityLabelStyleWhiteBox) {
      _bezelView.backgroundColor = [UIColor clearColor];
      self.backgroundColor = [UIColor whiteColor];
    } else if (_style == TTActivityLabelStyleBlackBox) {
      _bezelView.backgroundColor = [UIColor clearColor];
      self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    } else if (_style == TTActivityLabelStyleBlackBanner) {
      _bezelView.backgroundColor = [UIColor clearColor];
      _bezelView.style = TTSTYLE(blackBanner);
      self.backgroundColor = [UIColor clearColor];
    } else {
      _bezelView.backgroundColor = [UIColor clearColor];
      self.backgroundColor = [UIColor clearColor];
    }

    _label = [[UILabel alloc] init];
    _label.text = text;
    _label.backgroundColor = [UIColor clearColor];
    _label.lineBreakMode = UILineBreakModeTailTruncation;
        
    if (_style == TTActivityLabelStyleWhite) {
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                            UIActivityIndicatorViewStyleWhite];
      _label.font = TTSTYLEVAR(activityLabelFont);
      _label.textColor = [UIColor whiteColor];
    } else if (_style == TTActivityLabelStyleGray
               || _style == TTActivityLabelStyleWhiteBox
               || _style == TTActivityLabelStyleWhiteBezel) {
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                            UIActivityIndicatorViewStyleGray];
      _label.font = TTSTYLEVAR(activityLabelFont);
      _label.textColor = TTSTYLEVAR(tableActivityTextColor);
    } else if (_style == TTActivityLabelStyleBlackBezel || _style == TTActivityLabelStyleBlackBox) {
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                            UIActivityIndicatorViewStyleWhiteLarge];
      _activityIndicator.frame = CGRectMake(0, 0, 24, 24);
      _label.font = TTSTYLEVAR(activityLabelFont);
      _label.textColor = [UIColor whiteColor];
      _label.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
      _label.shadowOffset = CGSizeMake(1, 1);
    } else if (_style == TTActivityLabelStyleBlackBanner) {
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                            UIActivityIndicatorViewStyleWhite];
      _label.font = TTSTYLEVAR(activityBannerFont);
      _label.textColor = [UIColor whiteColor];
      _label.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
      _label.shadowOffset = CGSizeMake(1, 1);
    }
    
    [self addSubview:_bezelView];
    [_bezelView addSubview:_activityIndicator];
    [_bezelView addSubview:_label];
    [_activityIndicator startAnimating];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame style:(TTActivityLabelStyle)style {
  return [self initWithFrame:frame style:style text:nil];
}

- (id)initWithStyle:(TTActivityLabelStyle)style {
  return [self initWithFrame:CGRectZero style:style text:nil];
}

- (id)initWithFrame:(CGRect)frame {
  return [self initWithFrame:frame style:TTActivityLabelStyleWhiteBox text:nil];
}

- (void)dealloc {
  TT_RELEASE_TIMER(_smoothTimer);
  TT_RELEASE_SAFELY(_bezelView);
  TT_RELEASE_SAFELY(_progressView);
  TT_RELEASE_SAFELY(_activityIndicator);
  TT_RELEASE_SAFELY(_label);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
  [super layoutSubviews];

  CGSize textSize = [_label.text sizeWithFont:_label.font];

  CGFloat indicatorSize = 0;
  [_activityIndicator sizeToFit];
  if (_activityIndicator.isAnimating) {
    if (_activityIndicator.height > textSize.height) {
      indicatorSize = textSize.height;
    } else {
      indicatorSize = _activityIndicator.height;
    }
  }
  
  CGFloat contentWidth = indicatorSize + kSpacing + textSize.width;
  CGFloat contentHeight = textSize.height > indicatorSize ? textSize.height : indicatorSize;

  if (_progressView) {
    [_progressView sizeToFit];
    contentHeight += _progressView.height + kSpacing;
  }

  CGFloat margin, padding, bezelWidth, bezelHeight;
  if (_style == TTActivityLabelStyleBlackBezel || _style == TTActivityLabelStyleWhiteBezel) {
    margin = kMargin;
    padding = kPadding;
    bezelWidth = contentWidth + padding*2;
    bezelHeight = contentHeight + padding*2;
  } else {
    margin = 0;
    padding = kBannerPadding;
    bezelWidth = self.width;
    bezelHeight = self.height;
  }

  CGFloat maxBevelWidth = TTScreenBounds().size.width - margin*2;
  if (bezelWidth > maxBevelWidth) {
    bezelWidth = maxBevelWidth;
    contentWidth = bezelWidth - (kSpacing + indicatorSize);
  }
  
  CGFloat textMaxWidth = (bezelWidth - (indicatorSize + kSpacing)) - padding*2;
  CGFloat textWidth = textSize.width;
  if (textWidth > textMaxWidth) {
    textWidth = textMaxWidth;
  }
      
  _bezelView.frame = CGRectMake(floor(self.width/2 - bezelWidth/2),
                                floor(self.height/2 - bezelHeight/2),
                                bezelWidth, bezelHeight);
  
  CGFloat y = padding + floor((bezelHeight - padding*2)/2 - contentHeight/2);
  
  if (_progressView) {
    if (_style == TTActivityLabelStyleBlackBanner) {
      y += kBannerPadding/2;
    }
    _progressView.frame = CGRectMake(kProgressMargin, y,
                                     bezelWidth - kProgressMargin*2, _progressView.height);
    y += _progressView.height + kSpacing-1;
  }
  
  _label.frame = CGRectMake(floor((bezelWidth/2 - contentWidth/2) + indicatorSize + kSpacing), y,
                            textWidth, textSize.height);

  _activityIndicator.frame = CGRectMake(_label.left - (indicatorSize+kSpacing), y,
                                        indicatorSize, indicatorSize);
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGFloat padding;
  if (_style == TTActivityLabelStyleBlackBezel || _style == TTActivityLabelStyleWhiteBezel) {
    padding = kPadding;
  } else {
    padding = kBannerPadding;
  }

  CGFloat height = _label.font.lineHeight + padding*2;
  if (_progressView) {
    height += _progressView.height + kSpacing;
  }

  return CGSizeMake(size.width, height);
}

- (void)smoothTimer {
  if (_progressView.progress < _progress) {
    _progressView.progress += 0.01;
  } else {
    TT_RELEASE_TIMER(_smoothTimer);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (NSString*)text {
  return _label.text;
}

- (void)setText:(NSString*)text {
  _label.text = text;
  [self setNeedsLayout];
}

- (UIFont*)font {
  return _label.font;
}

- (void)setFont:(UIFont*)font {
  _label.font = font;
  [self setNeedsLayout];
}

- (BOOL)isAnimating {
  return _activityIndicator.isAnimating;
}

- (void)setIsAnimating:(BOOL)isAnimating {
  if (isAnimating) {
    [_activityIndicator startAnimating];
  } else {
    [_activityIndicator stopAnimating];
  }
}

- (void)setProgress:(float)progress {
  _progress = progress;
  
  if (!_progressView) {
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.progress = 0;
    [_bezelView addSubview:_progressView];
    [self setNeedsLayout];
  }

  if (_smoothesProgress) {
    if (!_smoothTimer) {
      _smoothTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self
                              selector:@selector(smoothTimer) userInfo:nil repeats:YES];
    }
  } else {
    _progressView.progress = progress;
  }
}

@end
