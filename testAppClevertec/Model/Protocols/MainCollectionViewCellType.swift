//
//  MainCollectionViewCellDelegate.swift
//  testAppClevertec
//
//  Created by Apple on 28.03.22.
//

import Foundation

protocol MainCollectionViewCellDelegate: AnyObject {
    func markMovie(movie: Movie) -> Bool
}
