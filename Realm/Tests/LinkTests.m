////////////////////////////////////////////////////////////////////////////
//
// TIGHTDB CONFIDENTIAL
// __________________
//
//  [2011] - [2014] TightDB Inc
//  All Rights Reserved.
//
// NOTICE:  All information contained herein is, and remains
// the property of TightDB Incorporated and its suppliers,
// if any.  The intellectual and technical concepts contained
// herein are proprietary to TightDB Incorporated
// and its suppliers and may be covered by U.S. and Foreign Patents,
// patents in process, and are protected by trade secret or copyright law.
// Dissemination of this information or reproduction of this material
// is strictly forbidden unless prior written permission is obtained
// from TightDB Incorporated.
//
////////////////////////////////////////////////////////////////////////////

#import "RLMTestCase.h"
#import "XCTestCase+AsyncTesting.h"

@interface DogObject : RLMObject
@property NSString *dogName;
@end

@implementation DogObject
@end

@interface OwnerObject : RLMObject
@property NSString *name;
@property DogObject *dog;
@end

@implementation OwnerObject
@end


@interface LinkTests : RLMTestCase
@end

@implementation LinkTests

- (void)testBasicLink {
    RLMRealm *realm = [self realmWithTestPath];
    
    OwnerObject *owner = [[OwnerObject alloc] init];
    owner.name = @"Tim";
    owner.dog = [[DogObject alloc] init];
    owner.dog.dogName = @"Harvie";
    
    [realm beginWriteTransaction];
    [realm addObject:owner];
    [realm commitWriteTransaction];
    
    RLMArray *owners = [realm objects:OwnerObject.className where:nil];
    RLMArray *dogs = [realm objects:DogObject.className where:nil];
    XCTAssertEqual(owners.count, 1, @"Expecting 1 owner");
    XCTAssertEqual(dogs.count, 1, @"Expecting 1 dog");
    XCTAssertEqualObjects([owners[0] name], @"Tim", @"Tim is named Tim");
    XCTAssertEqualObjects([dogs[0] dogName], @"Harvie", @"Harvie is named Harvie");
    
    OwnerObject *tim = owners[0];
    XCTAssertEqualObjects(tim.dog.dogName, @"Harvie", @"Tim's dog should be Harvie");
}

- (void)testMultipleOwnerLink {
    RLMRealm *realm = [self realmWithTestPath];
    
    OwnerObject *owner = [[OwnerObject alloc] init];
    owner.name = @"Tim";
    owner.dog = [[DogObject alloc] init];
    owner.dog.dogName = @"Harvie";
    
    [realm beginWriteTransaction];
    [realm addObject:owner];
    [realm commitWriteTransaction];
    
    XCTAssertEqual([realm objects:OwnerObject.className where:nil].count, 1, @"Expecting 1 owner");
    XCTAssertEqual([realm objects:DogObject.className where:nil].count, 1, @"Expecting 1 dog");
    
    [realm beginWriteTransaction];
    OwnerObject *fiel = [OwnerObject createInRealm:realm withObject:@[@"Fiel", NSNull.null]];
    fiel.dog = owner.dog;
    [realm commitWriteTransaction];
    
    XCTAssertEqual([realm objects:OwnerObject.className where:nil].count, 2, @"Expecting 2 owners");
    XCTAssertEqual([realm objects:DogObject.className where:nil].count, 1, @"Expecting 1 dog");
}

//- (void)testLinkRemoval {
//    RLMRealm *realm = [self realmWithTestPath];
//    
//    OwnerObject *owner = [[OwnerObject alloc] init];
//    owner.name = @"Tim";
//    owner.dog = [[DogObject alloc] init];
//    owner.dog.dogName = @"Harvie";
//    
//    [realm beginWriteTransaction];
//    [realm addObject:owner];
//    [realm commitWriteTransaction];
//    
//    XCTAssertEqual([realm objects:OwnerObject.className where:nil].count, 1, @"Expecting 1 owner");
//    XCTAssertEqual([realm objects:DogObject.className where:nil].count, 1, @"Expecting 1 dog");
//    
//    [realm beginWriteTransaction];
//    [realm deleteObject:owner.dog];
//    [realm commitWriteTransaction];
//    
//    // FIXME - re-enable once we fix accessor updates
//    // XCTAssertNil(owner.dog, @"Dog should be nullified when deleted");
//
//    // refresh owner and check
//    owner = [realm allObjects:OwnerObject.className].firstObject;
//    XCTAssertNotNil(owner, @"Should have 1 owner");
//    XCTAssertNil(owner.dog, @"Dog should be nullified when deleted");
//    XCTAssertEqual([realm objects:DogObject.className where:nil].count, 0, @"Expecting 0 dogs");
//}

@end

