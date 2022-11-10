//
//  Laboratory.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import Foundation
import SwiftUI
import UIKit
import GooglePlaces
import GoogleMaps

struct Laboratory: View {
    
    @State private var isGooglePlaceSearchOpened = false
    @State private var googlePlaceSearchAddress = ""
    
    var body: some View {
        GooglePlacePicker(
            address: $googlePlaceSearchAddress,
            onSearchResult: { place in
//                if let searchCafeInfo = cafeViewModel.getCafeInfoFromPlace(place: place) {
//                    cafeViewModel.clearUserMapModal()
//                    cafeViewModel.getModalCafePlaceInfo(googlePlaceId: searchCafeInfo.googlePlaceId)
//                    cafeViewModel.userMapModalCafeIndex = 0
//                    cafeViewModel.userMapModalCafeInfo = searchCafeInfo
//
//                    animateTo = GMSCameraPosition.camera(
//                        withLatitude: place.coordinate.latitude,
//                        longitude: place.coordinate.longitude,
//                        zoom: GlobalZoom.Large.rawValue
//                    )
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//                        isBottomSheetOpened = true
//                    }
//                } else {
//
//                }
            }
        )
    }
}

struct GooglePlacePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentationMode
    @Binding var address: String
    let onSearchResult: (GMSPlace) -> Void
    
    func makeCoordinator() -> GooglePlacesCoordinator {
        GooglePlacesCoordinator(parent: self, onSearchResult: onSearchResult)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<GooglePlacePicker>) -> GMSAutocompleteViewController {

        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator
        

        let fields: GMSPlaceField = GMSPlaceField(
            rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue)
        )
        
        autocompleteController.placeFields = fields

        let filter = GMSAutocompleteFilter()
        filter.locationBias = GMSPlaceRectangularLocationOption (
            CLLocationCoordinate2D(latitude: 37.748887, longitude: 127.418066),
            CLLocationCoordinate2D(latitude: 37.338261, longitude: 126.549068)
        )
        autocompleteController.autocompleteFilter = filter
        return autocompleteController
    }

    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: UIViewControllerRepresentableContext<GooglePlacePicker>) {
    }
    
    

    class GooglePlacesCoordinator: NSObject, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate {

        var parent: GooglePlacePicker
        var onSearchResult: (GMSPlace) -> Void

        init(parent: GooglePlacePicker, onSearchResult: @escaping (GMSPlace) -> Void) {
            self.parent = parent
            self.onSearchResult = onSearchResult
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            DispatchQueue.main.async {
                self.parent.address =  place.name!
                self.parent.presentationMode.wrappedValue.dismiss()
                self.onSearchResult(place)
            }
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            print("Error: ", error.localizedDescription)
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}
