//
//  AppConstants.swift
//  CabDispatch
//
//  Created by Dylan on 5/2/15.
//  Copyright (c) 2015 Dylan. All rights reserved.
//

import Foundation

struct AppConstants {
    
    struct ServerDomains {
        static let DispatchAPI = "http://dispatchapi.azurewebsites.net/api"
    }
    
    struct ControllerActions {
        
        // Driver actions
        
            static let AllDrivers = ("GET", "/AllDrivers")
            static let GetDriverLocation = ("GET", "/GetDriverLocation?")
            static let GetDriverWithDevice = ("GET", "/GetDriverWithDevice?")
            static let GetCustomerLocations = ("GET", "/GetCustomerLocations?")
            static let CreateDriver = ("POST", "/CreateDriver", true)
            static let RejectFare = ("POST", "/RejectFare?", true)
            static let UpdateDriver = ("PUT", "/UpdateDriver", true)
            static let PatchDriver = ("PATCH", "/PatchDriver", true)
            static let AcceptFare = ("PATCH", "/AcceptFare?")
            static let Dropoff = ("PATCH", "/Dropoff?", true)
            static let FireDriver = ("DELETE", "/FireDriver?")
        
        // Customer actions
        
            static let AllCustomers = ("GET", "/AllCustomers")
            static let GetCustomer = ("GET", "/GetCustomer?")
            static let GetCustomerWithDevice = ("GET", "/GetCustomerWithDevice?")
            static let CreateCustomer = ("POST", "/CreateCustomer", true)
            static let UpdateCustomer = ("PUT", "/UpdateCustomer", true)
            static let PatchCustomer = ("PATCH", "/PatchCustomer", true)
            static let DeleteCustomer = ("DELETE", "/DeleteCustomer?")
        
        // FareRequest actions
        
            static let AllFares = ("GET", "/AllFares")
            static let GetFare = ("GET", "/GetFare?")
            static let CustomersBy = ("GET", "/CustomersBy?")
            static let AllEmptyDrivers = ("GET", "/AllEmptyDrivers")
            static let RequestFare = ("POST", "/RequestFare", true)
            static let UpdateFare = ("PUT", "/UpdateFare?", true)
            static let AssignFare = ("PATCH", "/AssignFare?")
            static let CancelFare = ("DELETE", "/CancelFare?")
        
    }
    
    struct ServerControllers {
        static let Driver = "/Driver"
        static let Customer = "/Customer"
        static let FareRequest = "/FareRequest"
    }
    
    
}

struct RequestBodyObjectType {
    static let Customer = true
    static let Driver = true
    static let FareRequest = true
}
