//
//  DetailViewController.swift
//  LocallySourced
//
//  Created by C4Q on 3/3/18.
//  Copyright © 2018 TeamLocallySourced. All rights reserved.
//

import UIKit
import SnapKit
import MapKit

class DetailViewController: UIViewController {

    private lazy var detailView = DetailView(frame: self.view.safeAreaLayoutGuide.layoutFrame)
    
    private var market: FarmersMarket!
    
    private var address: String {
        return "\(market.facilitystreetname ?? "No Street Name Available"), \(market.facilitycity?.rawValue ?? "No City Name Available"), \(market.facilitystate) \(market.facilityzipcode ?? "No Zipcode Available")".replacingOccurrences(of: "&", with: "and")
    }
    
    init(market: FarmersMarket) {
        self.market = market
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigation()
    }
    
    private func setUpViews() {
        detailView.mapView.isHidden = true
        self.view.addSubview(detailView)
        detailView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        detailView.marketNameLabel.text = market.facilityname
        detailView.addressLabel.text = "\(market.facilitystreetname ?? "No Street Name Available"), \(market.facilitycity?.rawValue ?? "No City Name Available"), \(market.facilitystate) \(market.facilityzipcode ?? "No Zipcode Available")"
        let address = detailView.addressLabel.text!.replacingOccurrences(of: "&", with: "and")
        
        LocationService.manager.getCityCordinateFromCityName(inputAddress: address, completion: { [weak self] (location) in
            self?.detailView.mapView.isHidden = false
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 400, 400)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            self?.detailView.mapView.addAnnotation(annotation)
            self?.detailView.mapView.setRegion(region, animated: false)
        }, errorHandler: { [weak self] (error) in
            print("Could not get location: \(error)")
            //to do - hide map view!!
            self?.detailView.addressLabel.snp.removeConstraints()
            self?.detailView.addressLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(self!.detailView.marketNameLabel.snp.bottom).offset(20)
                make.width.equalTo(self!.detailView).multipliedBy(0.7)
                    make.centerX.equalTo(self!.detailView)
            })
            UIView.animate(withDuration: 0.5, animations: {
                self?.detailView.layoutIfNeeded()
            })
        })
        
        detailView.directionsButton.addTarget(self, action: #selector(directionsButtonTapped), for: .touchUpInside)
    }
    
    private func setUpNavigation() {
        var heartImage: UIImage?
        let alreadySaved = FileManagerHelper.manager.alreadySavedFarmersMarket(market)
        //if not favorited
        if alreadySaved {
            heartImage = UIImage(named: "fillHeartIcon")?.withRenderingMode(.alwaysOriginal)
        } else { //if favorited
            heartImage = UIImage(named: "unfillHeartIcon")?.withRenderingMode(.alwaysOriginal)
        }
        
        let saveBarButtonItem = UIBarButtonItem(image: heartImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveMarket(sender:)))
        let addItemBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "shoppingIcon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addShoppingList))
        self.navigationItem.rightBarButtonItems = [saveBarButtonItem, addItemBarButtonItem]
    }
    
    @objc private func saveMarket(sender: UIBarButtonItem) {
        //to do - add to saving with file manager
        print("save item!!")
        let heartUnfilled = UIImage(named: "unfillHeartIcon")?.withRenderingMode(.alwaysOriginal)
        let heartFilled = UIImage(named: "fillHeartIcon")?.withRenderingMode(.alwaysOriginal)
        
        if sender.image == heartFilled {
            sender.image = heartUnfilled
            //to do - remove from favorites
            FileManagerHelper.manager.removeFarmersMarket(market)
        } else {
            sender.image = heartFilled
            //to do - add to favorites
            FileManagerHelper.manager.addNewFarmersMarket(market)
        }
    }
    
    @objc private func addShoppingList() {
        print("add shopping list!!")
        let shoppingList = List(title: market.facilityname, items: [])
        let alreadySaved = FileManagerHelper.manager.alreadySavedShoppingList(shoppingList)
        //if the shopping list already exists
        if alreadySaved {
            let list = FileManagerHelper.manager.retrieveSavedShoppingLists().filter({ (savedList) -> Bool in
                return savedList.title == self.market.facilityname
            })[0]
            let detailShoppingListVC = DetailShoppingListViewController(list: list)
            self.navigationController?.pushViewController(detailShoppingListVC, animated: true)
        } else { //if not - success alert
            let alertController = UIAlertController(title: "Success", message: "A shopping list has been added for \(market.facilityname).", preferredStyle: .alert)
            FileManagerHelper.manager.addNewShoppingList(shoppingList)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: {(_) in
                //dependency injection
                let detailShoppingListVC = DetailShoppingListViewController(list: shoppingList)
                self.navigationController?.pushViewController(detailShoppingListVC, animated: true)
            })
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc private func directionsButtonTapped() {
        print("directions button tapped!!")
        guard let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL(string: "http://maps.apple.com/?daddr=\(encodedAddress)") else {
            print("couldn't get encoded address or url")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
