//
// PickupRequest.swift
//
// Auto-generated by GSParseSchema on 12/17/15.
// https://github.com/Grepstar/GSParseSchema
//

import Parse

class PickupRequest : PFObject, PFSubclassing {

	override class func initialize() {
		struct Static {
			static var onceToken : dispatch_once_t = 0;
		}
		dispatch_once(&Static.onceToken) {
			self.registerSubclass()
		}
	}

	class func parseClassName() -> String {
		return "PickupRequest"
	}
    
    func pickupLocationCoordinates() -> CLLocationCoordinate2D? {
        guard let pickupLocation = location else {
            return nil
        }
        
        let latitude = pickupLocation.latitude
        let longitude = pickupLocation.longitude
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return coordinates
        
    }

	// MARK: Parse Keys

	enum Keys: String {
		case confirmedVolunteer = "confirmedVolunteer"
		case pendingVolunteer = "pendingVolunteer"
		case note = "note"
		case donation = "donation"
		case isActive = "isActive"
		case address = "address"
		case donationCategories = "donationCategories"
		case donor = "donor"
		case location = "location"
	}

	// MARK: Properties

	@NSManaged var confirmedVolunteer: User?
	@NSManaged var pendingVolunteer: User?
	@NSManaged var note: String?
	@NSManaged var donation: Donation?
	var isActive: Bool? {
		get { return self["isActive"] as? Bool }
		set { return self["isActive"] = newValue }
	}
	@NSManaged var address: String?
	@NSManaged var donationCategories: [DonationCategory]?
	@NSManaged var donor: User?
	@NSManaged var location: PFGeoPoint?
}