//
//  TabBarController.swift
//  testAppClevertec
//
//  Created by Apple on 18.03.22.
//

import UIKit

class TabBarController: UITabBarController {
    
    struct Properties {
        static let mainName = "main"
        static let mainImage = UIImage(systemName: "list.bullet")
        static let favoritesName = "favorites"
        static let favoritesImage = UIImage(systemName: "heart")
        static let backgroundColor = UIColor.white
        static let barTintColor = UIColor.systemGray6
        static let selectedItemTintColor = UIColor.darkGray
        static let unselectedItemTintColor = UIColor.systemGray2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Properties.backgroundColor
        tabBar.barTintColor = Properties.barTintColor
        tabBar.tintColor = Properties.selectedItemTintColor
        tabBar.unselectedItemTintColor = Properties.unselectedItemTintColor
        let main = MainViewController()
        let favorites = FavoritesViewController()
        main.tabBarItem = UITabBarItem(title: Properties.mainName, image: Properties.mainImage, tag: 0)
        favorites.tabBarItem = UITabBarItem(title: Properties.favoritesName, image: Properties.favoritesImage, tag: 1)
        viewControllers = [main, favorites]
    }
}
