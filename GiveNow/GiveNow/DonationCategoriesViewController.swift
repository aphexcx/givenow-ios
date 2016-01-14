//
//  DonationCategoriesViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/7/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import MapKit
import Parse

private let reuseIdentifier = "donationCategory"
private let backend = Backend.sharedInstance()

class DonationCategoriesViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITextFieldDelegate, ModalBackgroundViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var donationCategories:[DonationCategory]!
    var location:CLLocationCoordinate2D!
    var address:String!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var pickupRequestAddressLabel: UILabel!
    @IBOutlet weak var noteTextField: UITextField!
    
    // MARK: - Nib setup
    let loginModalViewController = LoginModalViewController(nibName: "LoginModalViewController", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextField.delegate = self
        fetchDonationCategories()
        pickupRequestAddressLabel.text = address
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    // MARK: Getting data from Parse
    
    func fetchDonationCategories(){
        let query = backend.queryTopNineDonationCategories()
        backend.fetchDonationCategoriesWithQuery(query, completionHandler: {(result, error) -> Void in
            if error != nil {
                print(error)
            }
            else {
                self.donationCategories = result as! [DonationCategory]
                self.collectionView.reloadData()
            }
        })
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if donationCategories != nil {
            return donationCategories.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DonationCategoryCollectionViewCell
        let donationCategory = donationCategories[indexPath.row]
        configureDonationCategoryCell(cell, donationCategory: donationCategory)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //Assuming a margin of 10.0, and three columns
        let dimension = (view.frame.width - 40) / 3
        let size = CGSize(width: dimension, height: dimension)
        return size
    }
    
    func configureDonationCategoryCell(cell: DonationCategoryCollectionViewCell, donationCategory: DonationCategory) {
        
        addImageToCell(cell, donationCategory: donationCategory)
        cell.categoryLabel.text = donationCategory.getName()
        
        if donationCategory.selected == true {
            highlightCell(cell)
        }
        else {
            unHighlightCell(cell)
        }
    }
    
    func addImageToCell(cell: DonationCategoryCollectionViewCell, donationCategory: DonationCategory) {
        backend.getImageForDonationCategory(donationCategory, completionHandler: {(image, error) -> Void in
            if image != nil {
                cell.categoryImage.image = image
            }
            else if error != nil {
                print(error)
            }
        })
    }
    
    //MARK: Selecting cells
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let donationCategory = donationCategories[indexPath.row]
        
        if donationCategory.selected == nil || donationCategory.selected == false {
            donationCategory.selected = true
        }
        else {
            donationCategory.selected = false
        }
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    func highlightCell(cell: DonationCategoryCollectionViewCell) {
        cell.categoryLabel.backgroundColor = UIColor.colorAccent()
        cell.categoryLabel.textColor = UIColor.whiteColor()
    }
    
    func unHighlightCell(cell: DonationCategoryCollectionViewCell) {
        cell.categoryLabel.backgroundColor = UIColor.lightGrayColor()
        cell.categoryLabel.textColor = UIColor.whiteColor()
    }
    
    //MARK: Completing selection
    
    @IBAction func giveNowButtonTapped(sender: AnyObject) {
        if AppState.sharedInstance().isUserRegistered {
            savePickupRequest()
        }
        else {
            createModalBackgroundView()
        }
    }
    
    func createModalBackgroundView() {
        let modalBackground = ModalBackgroundViewController()
        modalBackground.modalPresentationStyle = .OverFullScreen
        modalBackground.modalTransitionStyle = .CrossDissolve
        modalBackground.delegate = self
        presentViewController(modalBackground, animated: true, completion: {})
    }
    
    func savePickupRequest() {
        let selectedDonationCategories = donationCategories.filter() {$0.selected == true}
        let latitude = location.latitude
        let longitude = location.longitude
        let pfLocation = PFGeoPoint(latitude: latitude, longitude: longitude)
        let note = noteTextField.text
        backend.savePickupRequest(selectedDonationCategories, address: address, location: pfLocation, note: note, completionHandler: { (result, error) -> Void in
            if error != nil {
                print(error)
            }
            else {
                self.performSegueWithIdentifier("newPickupRequestCreated", sender: nil)
            }
        })
    }
    
    func modalViewDismissedWithResult(controller: ModalBackgroundViewController) {
        savePickupRequest()
    }

}
