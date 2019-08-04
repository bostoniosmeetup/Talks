//
//  AddFriendViewModelTests.swift
//  Friends
//
//  Created by Jussi Suojanen on 22/04/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import XCTest

class AddFriendViewModelTests: XCTestCase {

    // MARK: Scenerio
    
    // Scenerio: Successfully add a friend to API
    func testAddFriendSuccess() {
        
        // Given: A API Client
        let appServerClient = MockAppServerClient()
        // Given: Successful Request
        appServerClient.postFriendResult = .success

        // Given: An AddFriendViewModel
        let viewModel = AddFriendViewModel(appServerClient: appServerClient)

        // Given: A Friend
        let mockFriend = Friend.with()
        viewModel.firstname = mockFriend.firstname
        viewModel.lastname = mockFriend.lastname
        viewModel.phonenumber = mockFriend.phonenumber

        // When: A new friend is posted to API
        viewModel.submitFriend()
        
        let expectNavigateCall = expectation(description: "Navigate back is called")
        
        // Then: Navigate back to list
        viewModel.navigateBack = {
            expectNavigateCall.fulfill()
        }
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    // Scenerio: API Request fails with good error
    func testAddFriendFailure() {
        // Given: A API Client
        let appServerClient = MockAppServerClient()
        // Given: Successful Request
        appServerClient.postFriendResult = .failure(AppServerClient.PostFriendFailureReason(rawValue: 401))
        // Given: An AddFriendViewModel
        let viewModel = AddFriendViewModel(appServerClient: appServerClient)

        // Given: A Friend
        let mockFriend = Friend.with()
        viewModel.firstname = mockFriend.firstname
        viewModel.lastname = mockFriend.lastname
        viewModel.phonenumber = mockFriend.phonenumber

        // When: A new friend is posted to the API
        viewModel.submitFriend()
        
        let expectErrorShown = expectation(description: "OnShowError is called")
        // Then: An Error is shown
        viewModel.onShowError = { error in
            expectErrorShown.fulfill() // We can make this better by asserting the error and adding a given error
        }
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    // Scenerio: Test all fields have valid input
    func testValidateInputSuccess() {
        // Given: A friend
        let mockFriend = Friend.with()
        // Given: A mock API client
        let appServerClient = MockAppServerClient()

        // Given: Am AddFriendViewModel
        let viewModel = AddFriendViewModel(appServerClient: appServerClient)

        let expectUpdateSubmitButtonStateCall = expectation(description: "updateSubmitButtonState is called")

        // When: All input fields have values
        viewModel.firstname = mockFriend.firstname
        viewModel.lastname = mockFriend.lastname
        viewModel.phonenumber = mockFriend.phonenumber
        
        // Then: Button state is enabled
        viewModel.updateSubmitButtonState = { state in
            XCTAssert(state == true, "testValidateInputData failed. Data should be valid")
            expectUpdateSubmitButtonStateCall.fulfill()
        }
        waitForExpectations(timeout: 0.1, handler: nil)
    }

}

// Mock Client
private final class MockAppServerClient: AppServerClient {
    var postFriendResult: AppServerClient.PostFriendResult?

    override func postFriend(firstname: String, lastname: String, phonenumber: String, completion: @escaping AppServerClient.PostFriendCompletion) {
        completion(postFriendResult!)
    }
}
