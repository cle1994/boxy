//
//  BXWorkoutViewController.m
//  Boxy
//
//  Created by Christian Le on 11/25/15.
//  Copyright © 2015 christianle. All rights reserved.
//

#import "BXWorkoutViewController.h"
#import "BXStyling.h"

@interface BXWorkoutViewController ()<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

// Workouts Table
@property (strong, nonatomic) UITableView *workoutsTableView;
@property (strong, nonatomic) UIButton *workoutsTableFooter;

// Workout Editing
@property (strong, nonatomic) UITextField *workoutNameEditTextField;
@property (strong, nonatomic) UIPickerView *workoutMetricsEditPickerView;
@property (strong, nonatomic) UIButton *workoutEditSaveButton;
@property (nonatomic) NSInteger selectedWorkout;

@end

static NSString *BXWorkoutsTableCellIdentifier = @"BXWorkoutsTableCellIdentifier";

// Picker Column 0 - Weight
static NSString *BXWeightString = @"Weight";
static int BXMaxWeight = 1000;
static int BXWeightIncrement = 5;

// Picker Column 1 - Sets
static NSString *BXSetsString = @"Sets";
static int BXMinSets = 1;
static int BXMaxSets = 10;

// Picker Column 2 - Reps;
static NSString *BXRepsString = @"Reps";
static int BXMinReps = 1;
static int BXMaxReps = 250;

@implementation BXWorkoutViewController
@synthesize workouts = _workouts;

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Edit Workout";
        self.navigationController.navigationBar.tintColor = [BXStyling lightColor];
        self.navigationController.navigationBar.barTintColor = [BXStyling lightColor];
        self.view.backgroundColor = [BXStyling lightColor];

        _workoutsTableFooter = [[UIButton alloc] init];
        _workoutsTableFooter.backgroundColor = [BXStyling primaryColor];
        [_workoutsTableFooter setTitle:@"Add" forState:UIControlStateNormal];
        [_workoutsTableFooter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_workoutsTableFooter addTarget:self action:@selector(addWorkout) forControlEvents:UIControlEventTouchUpInside];

        _workoutsTableView = [[UITableView alloc] init];
        _workoutsTableView.delegate = self;
        _workoutsTableView.dataSource = self;
        _workoutsTableView.allowsMultipleSelectionDuringEditing = NO;

        _workoutNameEditTextField = [[UITextField alloc] init];
        _workoutNameEditTextField.borderStyle = UITextBorderStyleRoundedRect;
        _workoutNameEditTextField.textColor = [BXStyling darkColor];
        _workoutNameEditTextField.placeholder = @"Workout Name";
        _workoutNameEditTextField.delegate = self;
        [_workoutNameEditTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        _workoutMetricsEditPickerView = [[UIPickerView alloc] init];
        _workoutMetricsEditPickerView.delegate = self;
        _workoutMetricsEditPickerView.dataSource = self;
        _workoutMetricsEditPickerView.backgroundColor = [UIColor whiteColor];

        _workoutEditSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _workoutEditSaveButton.backgroundColor = [BXStyling primaryColor];
        [_workoutEditSaveButton setTitle:@"Update" forState:UIControlStateNormal];
        [_workoutEditSaveButton addTarget:self action:@selector(saveEdit) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:_workoutsTableView];
        [self.view addSubview:_workoutsTableFooter];
        [self.view addSubview:_workoutNameEditTextField];
        [self.view addSubview:_workoutMetricsEditPickerView];
        [self.view addSubview:_workoutEditSaveButton];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self _installConstraints];
}

- (void)setWorkouts:(NSMutableArray *)workouts {
    _workouts = workouts;
}

- (void)updateEditorWithData:(NSDictionary *)data {
    [_workoutNameEditTextField setText:[data objectForKey:@"title"]];
    [_workoutMetricsEditPickerView selectRow:([data[@"sets"] integerValue])inComponent:0 animated:YES];
    [_workoutMetricsEditPickerView selectRow:([data[@"reps"] integerValue])inComponent:1 animated:YES];
    [_workoutMetricsEditPickerView selectRow:([data[@"weight"] integerValue] / 5)inComponent:2 animated:YES];
}

#pragma mark - Selectors

- (void)addWorkout {
    NSLog(@"Add Workout!");
    _selectedWorkout = [_workouts count];

    NSDictionary *data = @{ @"title": @"New Workout", @"weight": @(5), @"reps": @(1), @"sets": @(1) };
    _workouts[_selectedWorkout] = data;
    [_workoutsTableView reloadData];
    [self updateEditorWithData:data];
    [self.delegate refreshCurrentWorkout];

    NSIndexPath *row = [NSIndexPath indexPathForRow:([_workouts count] - 1)inSection:0];
    [_workoutsTableView selectRowAtIndexPath:row animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (void)textFieldDidChange:(id)sender {
}

- (void)saveEdit {
    _workouts[_selectedWorkout] = @{
        @"title": _workoutNameEditTextField.text,
        @"weight": @([_workoutMetricsEditPickerView selectedRowInComponent:2] * BXWeightIncrement),
        @"reps": @([_workoutMetricsEditPickerView selectedRowInComponent:1]),
        @"sets": @([_workoutMetricsEditPickerView selectedRowInComponent:0])
    };

    NSIndexPath *row = [NSIndexPath indexPathForRow:_selectedWorkout inSection:0];
    [_workoutsTableView reloadRowsAtIndexPaths:@[row] withRowAnimation:UITableViewRowAnimationLeft];
    [self.delegate updateCurrentWorkoutAtIndexPath:row];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_workouts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:BXWorkoutsTableCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BXWorkoutsTableCellIdentifier];
    }

    NSDictionary *cellInfo = [_workouts objectAtIndex:indexPath.row];
    [cell.textLabel setText:[cellInfo objectForKey:@"title"]];

    NSString *weight = [NSString stringWithFormat:@"%@", [cellInfo objectForKey:@"weight"]];
    NSString *sets = [NSString stringWithFormat:@"%@", [cellInfo objectForKey:@"sets"]];
    NSString *reps = [NSString stringWithFormat:@"%@", [cellInfo objectForKey:@"reps"]];

    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@x%@ %@ lbs.", sets, reps, weight]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row == _selectedWorkout) {
        _selectedWorkout = -1;
        [_workoutsTableView deselectRowAtIndexPath:[_workoutsTableView indexPathForSelectedRow] animated:YES];

        NSDictionary *data = @{ @"title": @"", @"weight": @(0), @"sets": @(0), @"reps": @(0) };
        [self updateEditorWithData:data];
    } else {
        _selectedWorkout = indexPath.row;

        NSDictionary *workout = [_workouts objectAtIndex:_selectedWorkout];
        [self updateEditorWithData:workout];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_workouts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.delegate refreshCurrentWorkout];
    }
}

#pragma mark - UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
    case 0:
        return BXMaxSets - BXMinSets + 1;
        break;
    case 1:
        return BXMaxReps - BXMinReps + 1;
        break;
    case 2:
        return BXMaxWeight / BXWeightIncrement + 1;
        break;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
    case 0:
        if (row == 0) {
            return BXSetsString;
        }
        return [@(row) stringValue];
        break;
    case 1:
        if (row == 0) {
            return BXRepsString;
        }
        return [@(row) stringValue];
        break;
    case 2:
        if (row == 0) {
            return BXWeightString;
        }
        return [@(row * 5) stringValue];
        break;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
}

#pragma mark - Constraints

- (void)_installConstraints {
    self.view.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);

    _workoutsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _workoutsTableFooter.translatesAutoresizingMaskIntoConstraints = NO;
    _workoutNameEditTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _workoutMetricsEditPickerView.translatesAutoresizingMaskIntoConstraints = NO;
    _workoutEditSaveButton.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *views = NSDictionaryOfVariableBindings(_workoutsTableView, _workoutsTableFooter, _workoutNameEditTextField, _workoutMetricsEditPickerView,
                                                         _workoutEditSaveButton);

    NSDictionary *metrics = @{ @"margin": @(20) };

    [self.view
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_workoutsTableView][_workoutsTableFooter]-margin-[_workoutNameEditTextField]-"
                                           @"margin-[_workoutMetricsEditPickerView]-margin-[_workoutEditSaveButton]-margin-|"
                                                               options:0
                                                               metrics:metrics
                                                                 views:views]];

    // _workoutsTableFooter
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_workoutsTableFooter]-|" options:0 metrics:metrics views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_workoutsTableFooter
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:40.0]];

    // _workoutsTableView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_workoutsTableView]-|" options:0 metrics:metrics views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_workoutsTableView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0.35
                                                           constant:0]];

    // _workoutNameEditTextField
    [self.view addConstraints:
                   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_workoutNameEditTextField]-margin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_workoutNameEditTextField
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:40.0]];
    // _workoutMetricsEditPickerView
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_workoutMetricsEditPickerView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];

    // _workoutEditSaveButton
    [self.view
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_workoutEditSaveButton]-margin-|" options:0 metrics:metrics views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_workoutEditSaveButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:40.0]];
}

@end
