//  ViewController.swift
//
//  Created by Prashant Rane.
//

import UIKit

class MainViewController: UIViewController {

  private var mainView: MainView {
    return view as! MainView
  }

  private var resultController = MovieResultsController()

  init() {
    super.init(nibName: nil, bundle: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.showError(notification:)), name: NSNotification.Name(rawValue: MovieSearchManager.Constants.errorNotificationKey), object: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    self.view = MainView(with: resultController, tableViewDatasource: resultController, searchBarDelegate: resultController)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("Search Movies", comment: "Navigation bar title for Main Screen")

    // Setup datasource
    resultController.setup(with: mainView.refresh, dismissSearchCallback: mainView.dismissSearch, activityIndicatorCallback: mainView.displayActivityIndicator)
    
    // Setup main view
    mainView.setup()
  }

  @objc func showError(notification: Notification) {
    guard let errorMessage = notification.userInfo?[MovieSearchManager.Constants.errorMessageKey] as? String else {
      return
    }

    // Hide activity indicator
    mainView.displayActivityIndicator(false)

    let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Title for OK button from error alert"), style: UIAlertActionStyle.default, handler: nil))

    present(alert, animated: true, completion: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()

    // Clear movie poster cache
    CacheManager.moviePosterCache.clearCache()
  }

}
