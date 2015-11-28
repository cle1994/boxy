//
//  BXHomeCurrentWorkoutViewController.m
//  Boxy
//
//  Created by Christian Le on 11/25/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXHomeWorkoutViewController.h"
#import "BXWorkoutViewcontroller.h"
#import "BXStyling.h"

typedef NS_ENUM(NSInteger, BXStringGeneratorType) {
    BXStringGeneratorTypeTitle,
    BXStringGeneratorTypeWeight,
    BXStringGeneratorTypeSets,
    BXStringGeneratorTypeReps
};

@interface BXHomeWorkoutViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UITableView *workoutTableView;
@property (strong, nonatomic) UILabel *workoutHeaderView;
@property (strong, nonatomic) UIButton *actionButton;
@property (strong, nonatomic) UIButton *secondaryActionButton;
@property (nonatomic) BXHomeActionType actionType;

@end

static NSString *BXCurrentWorkoutCellIdentifier = @"BXCurrentWorkoutCellIdentifier";
static CGFloat BXMargin = 10.0;
static CGFloat BXTableCellHeight = 25.0;
static CGFloat BXHeaderHeight = 40.0;
static CGFloat BXButtonHeight = 35.0;

@implementation BXHomeWorkoutViewController
@synthesize workouts = _workouts;

- (instancetype)initWithAction:(BXHomeActionType)action AndTitle:(NSString *)title AndWorkouts:(NSMutableArray *)workouts {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _workoutTableView = [[UITableView alloc] init];
        _workoutTableView.delegate = self;
        _workoutTableView.dataSource = self;
        _workoutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _workoutTableView.scrollEnabled = NO;
        _workoutTableView.allowsSelection = NO;

        _workoutHeaderView = [[UILabel alloc] init];
        _workoutHeaderView.text = title;
        _workoutHeaderView.textAlignment = NSTextAlignmentCenter;
        _workoutHeaderView.textColor = [BXStyling lightColor];
        _workoutHeaderView.backgroundColor = [BXStyling headerBackgroundColor];

        _workouts = workouts;

        self.view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_workoutHeaderView];
        [self.view addSubview:_workoutTableView];

        _actionType = action;
        switch (action) {
        case BXHomeActionTypeNone:
            _actionButton = nil;
            break;
        case BXHomeActionTypeTwitter:
            _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _actionButton.backgroundColor = [BXStyling primaryColor];
            [_actionButton setTitle:@"Post to Twitter" forState:UIControlStateNormal];
            [_actionButton addTarget:self action:@selector(actionPostTwitter) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_actionButton];
            break;
        case BXHomeActionTypeCurrent:
            _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _actionButton.backgroundColor = [BXStyling accentColor];
            [_actionButton setTitle:@"Edit" forState:UIControlStateNormal];
            [_actionButton addTarget:self action:@selector(actionEditWorkout) forControlEvents:UIControlEventTouchUpInside];

            _secondaryActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _secondaryActionButton.backgroundColor = [BXStyling primaryColor];
            [_secondaryActionButton setTitle:@"Send" forState:UIControlStateNormal];
            [_secondaryActionButton addTarget:self action:@selector(actionSyncWorkout) forControlEvents:UIControlEventTouchUpInside];

            [self.view addSubview:_actionButton];
            [self.view addSubview:_secondaryActionButton];
            break;
        default:
            break;
        }
    }

    return self;
}

- (instancetype)init {
    return [self initWithAction:BXHomeActionTypeNone AndTitle:@"" AndWorkouts:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGSize viewSize = self.view.frame.size;
    CGFloat tableHeight = BXTableCellHeight * [_workouts count];

    _workoutHeaderView.frame = CGRectMake(0, 0, viewSize.width, BXHeaderHeight);
    _workoutTableView.frame = CGRectMake(0, BXHeaderHeight + BXMargin, viewSize.width, tableHeight);

    if (_actionType == BXHomeActionTypeTwitter) {
        CGFloat buttonStart = BXHeaderHeight + (BXMargin * 2) + tableHeight;
        _actionButton.frame = CGRectMake((BXMargin * 1.5), buttonStart, viewSize.width - (BXMargin * 3), BXButtonHeight);
    } else if (_actionType == BXHomeActionTypeCurrent) {
        CGFloat buttonStart = BXHeaderHeight + (BXMargin * 2) + tableHeight;
        CGFloat buttonWidth = (viewSize.width - (BXMargin * 3) - BXMargin) / 2.0;
        _actionButton.frame = CGRectMake((BXMargin * 1.5), buttonStart, buttonWidth, BXButtonHeight);
        _secondaryActionButton.frame = CGRectMake((BXMargin * 1.5 + buttonWidth + BXMargin), buttonStart, buttonWidth, BXButtonHeight);
    }
}

- (void)setWorkouts:(NSMutableArray *)workouts {
    _workouts = workouts;
    [self refreshCurrentWorkout];
}

- (CGFloat)getViewHeight {
    CGFloat buttonHeight = 0;
    if (_actionType != BXHomeActionTypeNone) {
        buttonHeight += (BXMargin * 1.5) + BXButtonHeight;
    }

    return (BXMargin * 2) + BXHeaderHeight + (BXTableCellHeight * [_workouts count]) + buttonHeight;
}

- (NSString *)generateAckStringForIndex:(int)index AndMessage:(NSMutableArray *)message {
    if (index == 0) {
        NSString *ack = [[@"W" stringByAppendingString:[@([message count]) stringValue]] stringByAppendingString:@"-"];
        return [ack stringByAppendingString:message[0]];
    } else {
        NSString *ack = [[@"C" stringByAppendingString:[@(index + 1) stringValue]] stringByAppendingString:@"-"];
        return [ack stringByAppendingString:message[index]];
    }
}

- (NSArray *)generateStringMessage:(BXStringGeneratorType)messageType {
    NSMutableArray *message = [[NSMutableArray alloc] init];
    NSString *concat = @"";

    for (int i = 0; i < [_workouts count]; i++) {
        NSDictionary *data = _workouts[i];
        NSString *input = @"";
        NSString *type = @"";
        if (messageType == BXStringGeneratorTypeTitle) {
            input = data[@"title"];
            type = @"T-";
        } else if (messageType == BXStringGeneratorTypeWeight) {
            input = [NSString stringWithFormat:@"%@", [data objectForKey:@"weight"]];
            type = @"W-";
        } else if (messageType == BXStringGeneratorTypeSets) {
            input = [NSString stringWithFormat:@"%@", [data objectForKey:@"sets"]];
            type = @"S-";
        } else if (messageType == BXStringGeneratorTypeReps) {
            input = [NSString stringWithFormat:@"%@", [data objectForKey:@"reps"]];
            type = @"R-";
        }

        if (concat.length == 0) {
            concat = [type copy];
        }

        if (concat.length + input.length < 15) {
            concat = [concat stringByAppendingString:[input stringByAppendingString:@"-"]];
        } else {
            [message addObject:concat];
            concat = [[type stringByAppendingString:[input stringByAppendingString:@"-"]] copy];
        }
    }

    if (concat.length != 0) {
        [message addObject:concat];
    }

    return [message copy];
}

#pragma mark - Selectors

- (void)actionPostTwitter {
    NSString *tweet = @"My last workout from Boxy!\r\n";
    for (int i = 0; i < [_workouts count]; i += 1) {
        NSDictionary *exercise = [_workouts objectAtIndex:i];
        NSString *title = [exercise objectForKey:@"title"];
        NSString *weight = [NSString stringWithFormat:@"Weight: %@", [exercise objectForKey:@"weight"]];
        NSString *adding = [NSString stringWithFormat:@"%@: %@ lbs.\r\n", title, weight];
        if (tweet.length + adding.length <= 140) {
            tweet = [tweet stringByAppendingString:adding];
        }
    }
    [self.delegate sendToTwitter:tweet];
}

- (void)actionEditWorkout {
    BXWorkoutViewController *workoutViewController = [[BXWorkoutViewController alloc] init];
    workoutViewController.delegate = self;
    workoutViewController.workouts = _workouts;

    [self.navigationController pushViewController:workoutViewController animated:YES];
}

- (void)actionSyncWorkout {
    NSArray *titles = [self generateStringMessage:BXStringGeneratorTypeTitle];
    NSArray *weights = [self generateStringMessage:BXStringGeneratorTypeWeight];
    NSArray *reps = [self generateStringMessage:BXStringGeneratorTypeReps];
    NSArray *sets = [self generateStringMessage:BXStringGeneratorTypeSets];

    NSMutableArray *concat = [[NSMutableArray alloc] init];
    for (int i = 0; i < [titles count]; i++) {
        [concat addObject:titles[i]];
    }
    for (int i = 0; i < [weights count]; i++) {
        [concat addObject:weights[i]];
    }
    for (int i = 0; i < [sets count]; i++) {
        [concat addObject:sets[i]];
    }
    for (int i = 0; i < [reps count]; i++) {
        [concat addObject:reps[i]];
    }
    
    concat[0] = [self generateAckStringForIndex:0 AndMessage:concat];
    for (int i = 1; i < [concat count]; i++) {
        concat[i] = [self generateAckStringForIndex:i AndMessage:concat];
    }

    [self.delegate sendWorkout:[concat copy]];
}

#pragma mark BXHomeWorkoutViewController Delegate

- (void)updateCurrentWorkoutAtIndexPath:(NSIndexPath *)indexPath {
    [_workoutTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)refreshCurrentWorkout {
    [_workoutTableView reloadData];
    [self.delegate layoutSubviews];
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return BXTableCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_workouts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:BXCurrentWorkoutCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BXCurrentWorkoutCellIdentifier];
    }

    NSDictionary *cellInfo = [_workouts objectAtIndex:indexPath.row];
    [cell.textLabel setText:[cellInfo objectForKey:@"title"]];

    NSString *weight = [NSString stringWithFormat:@"%@", [cellInfo objectForKey:@"weight"]];
    NSString *sets = [NSString stringWithFormat:@"%@", [cellInfo objectForKey:@"sets"]];
    NSString *reps = [NSString stringWithFormat:@"%@", [cellInfo objectForKey:@"reps"]];

    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@x%@ %@ lbs.", sets, reps, weight]];
    return cell;
}

@end
