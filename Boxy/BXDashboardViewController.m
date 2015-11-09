//
//  BXDashboardViewController.m
//  Boxy
//
//  Created by Christian Le on 11/5/15.
//  Copyright © 2015 christianle. All rights reserved.
//

@import Charts;

#import "BXDashboardViewController.h"
#import "BXStyling.h"

@interface BXDashboardViewController ()<ChartViewDelegate>

@property (strong, nonatomic) LineChartView *lineChartView;
@property (strong, nonatomic) UILabel *helloCountView;

@end

@implementation BXDashboardViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Dashboard";
        self.navigationController.navigationBar.tintColor =
            [BXStyling lightColor];
        self.navigationController.navigationBar.barTintColor =
            [BXStyling lightColor];
        self.view.backgroundColor = [BXStyling lightColor];

        _helloCountView = [[UILabel alloc] init];
        _helloCountView.textAlignment = NSTextAlignmentCenter;
        _helloCountView.font = [UIFont systemFontOfSize:25];
        _helloCountView.backgroundColor = [BXStyling lightColor];
        _helloCountView.textColor = [BXStyling darkColor];

        [self.view addSubview:_lineChartView];
        [self.view addSubview:_helloCountView];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _lineChartView = [[LineChartView alloc] init];
    _lineChartView.delegate = self;
    _lineChartView.descriptionText = @"Last Workout";
    _lineChartView.noDataTextDescription = @"You need to supply data!";
    _lineChartView.dragEnabled = YES;
    _lineChartView.pinchZoomEnabled = YES;
    _lineChartView.drawGridBackgroundEnabled = NO;
    _lineChartView.xAxis.labelPosition = XAxisLabelPositionBottom;
    _lineChartView.xAxis.drawGridLinesEnabled = NO;

    ChartYAxis *leftAxis = _lineChartView.leftAxis;
    [leftAxis removeAllLimitLines];
    leftAxis.customAxisMax = 120.0;
    leftAxis.customAxisMin = -20.0;
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.drawGridLinesEnabled = NO;

    _lineChartView.legend.form = ChartLegendFormLine;

    _lineChartView.rightAxis.enabled = NO;
    [_lineChartView.viewPortHandler setMaximumScaleX:2.f];
    [_lineChartView.viewPortHandler setMaximumScaleY:2.];

    [self setDataCount:20 range:100.0];

    [_lineChartView animateWithXAxisDuration:3.0
                               yAxisDuration:3.0
                                easingOption:ChartEasingOptionEaseInOutQuart];
}

- (void)viewDidLayoutSubviews {
    CGSize viewSize = self.view.bounds.size;
    [_lineChartView setFrame:CGRectMake(20, 20, viewSize.width - 40,
                                        (viewSize.height * 0.5) - 0)];
    [_helloCountView
        setFrame:CGRectMake(0, viewSize.height * 0.5, viewSize.width,
                            viewSize.height * 0.5)];
}

- (void)handleReceivedData:(unsigned char *)data length:(int)length {
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s =
        [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);

    [self setDataCount:20 range:100.0];
    [_helloCountView setText:s];
}

- (void)setDataCount:(int)count range:(double)range {
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i += 1) {
        [xVals addObject:[@(i) stringValue]];
    }

    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i += 1) {
        double multiply = range + 1;
        double val = (double)(arc4random_uniform(multiply)) + 3;
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
    }

    LineChartDataSet *set =
        [[LineChartDataSet alloc] initWithYVals:yVals label:@"Last Import"];

    set.lineWidth = 2.0;
    set.circleRadius = 3.0;
    set.drawCircleHoleEnabled = NO;
    set.valueFont = [UIFont systemFontOfSize:10.0f];
    set.fillAlpha = 64 / 255.0;
    set.fillColor = [BXStyling primaryColor];
    set.highlightLineDashLengths = @[ @5.f, @2.5f ];
    set.drawCubicEnabled = YES;
    [set setColor:[BXStyling primaryColor]];
    [set setCircleColor:[BXStyling accentColor]];
    [set setHighlightColor:[BXStyling accentColor]];

    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set];

    LineChartData *data =
        [[LineChartData alloc] initWithXVals:xVals dataSet:set];

    _lineChartView.data = data;
    [_lineChartView notifyDataSetChanged];
    [_lineChartView animateWithXAxisDuration:3.0
                               yAxisDuration:3.0
                                easingOption:ChartEasingOptionEaseInOutQuart];
}

#pragma ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase *__nonnull)chartView
                     entry:(ChartDataEntry *__nonnull)entry
              dataSetIndex:(NSInteger)dataSetIndex
                 highlight:(ChartHighlight *__nonnull)highlight {
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase *__nonnull)chartView {
    NSLog(@"chartValueNothingSelected");
}

@end
