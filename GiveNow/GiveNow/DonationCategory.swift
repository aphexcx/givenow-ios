//
// DonationCategory.swift
//
// Auto-generated by GSParseSchema on 12/17/15.
// https://github.com/Grepstar/GSParseSchema
//

import Parse

class DonationCategory : PFObject, PFSubclassing {

	override class func initialize() {
		struct Static {
			static var onceToken : dispatch_once_t = 0;
		}
		dispatch_once(&Static.onceToken) {
			self.registerSubclass()
		}
	}

	class func parseClassName() -> String {
		return "DonationCategory"
	}
    
    func getName() -> String? {
        let preferredLanguage = NSLocale.preferredLanguages()[0]
        if preferredLanguage == "en-US" {
            return self.name_en
        }
        else if preferredLanguage == "de" || preferredLanguage == "de-US" {
            return self.name_de
        }
        else {
            print(preferredLanguage)
            return nil
        }
    }
    

	// MARK: Parse Keys

	enum Keys: String {
		case image = "image"
		case description_en = "description_en"
		case priority = "priority"
		case name_de = "name_de"
		case description_de = "description_de"
		case name_en = "name_en"
	}

	// MARK: Properties

	@NSManaged var image: PFFile?
	@NSManaged var description_en: String?
	@NSManaged var priority: NSNumber?
	@NSManaged var name_de: String?
	@NSManaged var description_de: String?
	@NSManaged var name_en: String?
    
    // MARK: Custom properties
    // Doing this as a workaround; could not get the collectionview cell selection to work
    var selected:Bool?
}