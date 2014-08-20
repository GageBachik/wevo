//
//  TCMasterViewController.m
//  TCKnowledgeGraph
//
//  Created by Lee Tze Cheun on 6/12/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCMasterViewController.h"
#import "TCFreebaseSearch.h"
#import "MBProgressHUD.h"
#import "Wevo-Swift.h"

@interface TCMasterViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSMutableArray *artistList;

@end

@implementation TCMasterViewController


#pragma mark - View Controller Life Cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.tableView reloadData];
    self.artistList = [[NSMutableArray alloc] init];
    
    // Set focus to the UISearchBar, so that user can start
    // entering their query right away.
    
    [self.searchBar becomeFirstResponder];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Show navigation bar for the detail view, so that we can navigate back to this search view.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Dismiss the keyboard when this view goes away.
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    self.searchResults = nil;
}

- (void)dealloc
{
    // Remember to nil out the UISearchBar's delegate property when we are deallocated.
    // Otherwise, UISearchBar will refer to a deallocated delegate.
    self.searchBar.delegate = nil;
}

#pragma mark - Search Bar Delegate

/* As user type we will fetch the list of search suggestions in the background. */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // If user deleted the search text, we should not waste resources sending an
    // empty query string to Freebase API.
    if (!searchText || 0 == [searchText length]) {
        self.searchResults = nil;
        [self.tableView reloadData];
        return;
    }
    
    // Fetch a list of suggested Freebase topics for the user's search text.
    [[TCFreebaseSearchService sharedService] searchForQuery:searchText completionHandler:^(NSArray *searchResults) {
        
        // It is possible that the UISearchBar's text has changed when we return
        // from the network with the search results. If it has changed, we should not
        // display stale results on the table view.
        if ([searchText isEqualToString:searchBar.text]) {
            self.searchResults = searchResults;
            [self.tableView reloadData];
        }
    }];
                
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}

#pragma mark - Table View Data Source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.searchResults) {
        return 0;
    }
    
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchSuggestionCell"
                                                            forIndexPath:indexPath];
        
    TCFreebaseSearchResult *searchResult = self.searchResults[indexPath.row];
    
    //NSLog(@"artist name: %@", searchResult.artistName);
    if (searchResult.artistName) {
        cell.textLabel.text = searchResult.topicName;
        cell.detailTextLabel.text = searchResult.artistName;
    }else{
        cell.textLabel.text = searchResult.topicName;
        cell.detailTextLabel.text = searchResult.notableName;
    }
    
    NSString *selectedTrack = [NSString stringWithFormat: @"%@ - %@ ", searchResult.artistName, searchResult.topicName];
    BOOL alreadySelectedTrack = [self.artistList containsObject: selectedTrack];
    NSString *selectedArtist = [NSString stringWithFormat: @"%@ - %@ ", searchResult.topicName, searchResult.notableName];
    BOOL alreadySelecteArtist = [self.artistList containsObject: selectedArtist];
    if (!alreadySelecteArtist && !alreadySelectedTrack){
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    TCFreebaseSearchResult *searchResult = self.searchResults[indexPath.row];
    // NSLog(@"%@", searchResult.topicName);
    
    if (searchResult.artistName) {
        NSString *selectedTrack = [NSString stringWithFormat: @"%@ - %@ ", searchResult.artistName, searchResult.topicName];
        NSString *and = @"&";
        if ([selectedTrack rangeOfString:and].location != NSNotFound) {
            selectedTrack = [selectedTrack stringByReplacingOccurrencesOfString:and withString:@"and"];
        }
        BOOL alreadySelectedTrack = [self.artistList containsObject: selectedTrack];
        if (!alreadySelectedTrack) {
            [self.artistList addObject: selectedTrack];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            NSLog(@"%@", self.artistList);
        }else {
            [self.artistList removeObjectAtIndex:[self.artistList indexOfObject: selectedTrack]];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSLog(@"%@", self.artistList);
        }
    }else {
        NSString *selectedArtist = [NSString stringWithFormat: @"%@ - %@ ", searchResult.topicName, searchResult.notableName];
        NSString *and = @"&";
        if ([selectedArtist rangeOfString:and].location != NSNotFound) {
            selectedArtist = [selectedArtist stringByReplacingOccurrencesOfString:and withString:@"and"];
        }
        BOOL alreadySelecteArtist = [self.artistList containsObject: selectedArtist];
        if (!alreadySelecteArtist){
            [self.artistList addObject: selectedArtist];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            NSLog(@"%@", self.artistList);
        }else {
            [self.artistList removeObjectAtIndex:[self.artistList indexOfObject: selectedArtist]];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSLog(@"%@", self.artistList);
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
// device setup
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Logout or Play
- (IBAction)didLogout:(id)sender {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [self performSegueWithIdentifier:@"didLogout" sender:nil];
}
- (IBAction)didPlay:(id)sender {
    [self.view endEditing:YES];
    if ([self.artistList count] > 0) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *token = [prefs stringForKey:@"token"];
        NSLog(@"artistlist - %@", self.artistList);
        Play * ply = [[Play alloc] init];
        [ply postToServer:self.artistList userId:token context:self];
    }

}
@end
