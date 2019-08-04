//
//  AddFriendViewModel.swift
//  Friends
//
//  Created by Jussi Suojanen on 06/01/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

// MARK: Protocols

protocol FriendViewModel {
    var title: String { get }
    var firstname: String? { get set }
    var lastname: String? { get set }
    var phonenumber: String? { get set }
    var showLoadingHud: Bindable<Bool> { get }

    var updateSubmitButtonState: ((Bool) -> ())? { get set }
    var navigateBack: (() -> ())?  { get set }
    var onShowError: ((_ alert: SingleButtonAlert) -> Void)?  { get set }

    func submitFriend()
}

final class AddFriendViewModel: FriendViewModel {
    
    // MARK: Computed Properties
    
    var title: String {
        return "Add Friend"
    }
    
    // MARK: Variable Properties
    
    var firstname: String? {
        didSet {
            validateInput()
        }
    }
    var lastname: String? {
        didSet {
            validateInput()
        }
    }
    var phonenumber: String? {
        didSet {
            validateInput()
        }
    }
    
    // MARK: Callbacks
    var updateSubmitButtonState: ((Bool) -> ())?
    var navigateBack: (() -> ())?
    var onShowError: ((_ alert: SingleButtonAlert) -> Void)?

    // MARK: Constants
    let showLoadingHud: Bindable = Bindable(false)

    private let appServerClient: AppServerClient
    private var validInputData: Bool = false {
        didSet {
            if oldValue != validInputData {
                updateSubmitButtonState?(validInputData)
            }
        }
    }

    // MARK: Initializers
    
    init(appServerClient: AppServerClient = AppServerClient()) {
        self.appServerClient = appServerClient
    }

    // MARK: Functions
    
    func submitFriend() {
        guard let firstname = firstname,
            let lastname = lastname,
            let phonenumber = phonenumber else {
                return
        }

        updateSubmitButtonState?(false)
        showLoadingHud.value = true

        appServerClient.postFriend(firstname: firstname, lastname: lastname, phonenumber: phonenumber) { [weak self] result in
            self?.showLoadingHud.value = false
            self?.updateSubmitButtonState?(true)
                switch result {
                case .success:
                    self?.navigateBack?()
                case .failure(let error):
                    let okAlert = SingleButtonAlert(
                        title: error?.getErrorMessage() ?? "Could not connect to server. Check your network and try again later.",
                        message: "Could not add \(firstname) \(lastname).",
                        action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                    )
                    self?.onShowError?(okAlert)
                }
        }
    }

    func validateInput() {
        let validData = [firstname, lastname, phonenumber].filter {
            ($0?.count ?? 0) < 1
        }
        validInputData = (validData.count == 0) ? true : false
    }
}

// MARK: Extensions

private extension AppServerClient.PostFriendFailureReason {
    func getErrorMessage() -> String? {
        switch self {
        case .unAuthorized:
            return "Please login to add friends friends."
        case .notFound:
            return "Failed to add friend. Please try again."
        }
    }
}
