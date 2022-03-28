//
//  ViewControllerType.swift
//  testAppClevertec
//
//  Created by Apple on 26.03.22.
//

import Foundation
import UIKit

protocol ViewControllerType {
    var moviesList: Box<[Movie]> { get set }
    var openMoviesList: Box<[Movie]> { get set }
    var savedMovieIds: Box<[Int]> { get set }
    var movieForDetails: Box<Movie?> { get set }
    var readyMoviesList: Box<[(Movie, Bool)]> { get set }
    func presentDetails(indexPath: Int)
    func handleAddition(movie: Movie)
    func getSearchResults(text: String?)
}



extension ViewControllerType {
    func refreshCollection() { }
    func testConnection() { }
    func updateData() { }
}


