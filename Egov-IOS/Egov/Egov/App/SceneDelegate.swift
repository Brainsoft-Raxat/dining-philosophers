//
//  SceneDelegate.swift
//  Egov
//
//  Created by Amirzhan Armandiyev on 15.04.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        var mainVC: UIViewController = MainAuthorizationVC(requestNumber: "")
        
        if let urlContext = connectionOptions.urlContexts.first {
            let url = urlContext.url
            
            if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                let params = components.queryItems {
                if let requestId = params.first(where: { $0.name == "request_id" })?.value {
                    mainVC = MainAuthorizationVC(requestNumber: requestId)
                }
            }
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()

        let navigationController = UINavigationController(rootViewController: mainVC)
//        let navigationController = UINavigationController(rootViewController: DeliveryInformationVC(networkingService: NetworkingService(), userName: UserName(firstName: "asdas", middleName: "dsadsa", lastName: "dsadsa", phone: "89219i312")))
//        let navigationController = UINavigationController(rootViewController: CourierVC(networkingService: NetworkingService(), userName: UserName(firstName: "asdas", middleName: "dsadsa", lastName: "dsadsa", phone: "89219i312")))
//        let navigationController = UINavigationController(rootViewController: PaymentVC(order: ResponseOrder(orderId: 10, branchName: "", price: 100, time: 100, distance: 100), networkingService: NetworkingService(), userName: UserName(firstName: "", middleName: "", lastName: "", phone: "")))
        window?.rootViewController = navigationController
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        var mainVC: UIViewController = MainAuthorizationVC(requestNumber: "")
        
        guard let url = URLContexts.first?.url else { return }
        
        if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let params = components.queryItems {
            if let requestId = params.first(where: { $0.name == "request_id" })?.value {
                mainVC = MainAuthorizationVC(requestNumber: requestId)
            }
        }
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()

        let navigationController = UINavigationController(rootViewController: mainVC)
        window?.rootViewController = navigationController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}

