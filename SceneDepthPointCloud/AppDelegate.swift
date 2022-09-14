/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the application's delegate.
*/

import UIKit
import ARKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
//        let DirPath = DocumentDirectory.appendingPathComponent("Pcd_Files")
//        do
//        {
//            try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
//        }
//        catch let error as NSError
//        {
//            print("Unable to create directory \(error.debugDescription)")
//        }
//        print("Dir Path = \(DirPath!)")
//
//        let pathscolor = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectorycolor = pathscolor[0]
//        let filecolor = documentsDirectorycolor.appendingPathComponent("Pcd_Files/ply_without_normal_.txt")
//
//        do {
//            print("File path : " + filecolor.absoluteString)
//            print("remove prefix : \(filecolor.absoluteString.deletingPrefix("file://"))")
//            // 7
//            var stringef = "dsfdfsgd"
//        try stringef.write(to: filecolor, atomically: true, encoding: String.Encoding.ascii)
//    } catch {
//        print("Failed to write PLY file", error)
//    }
        if !ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            // Ensure that the device supports scene depth and present
            //  an error-message view controller, if not.
            // Override point for customization after application launch.
           
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "ShowPointCloudViewController")
        } else {
            let vc = UIStoryboard.init(name: "Main", bundle : nil).instantiateViewController(withIdentifier: "Start_view_controller") as! Start_view_controller
                    let vcNav = UINavigationController(rootViewController: vc)
                    self.window?.rootViewController = vcNav
                    self.window?.makeKeyAndVisible()
        }
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

        print("Active ---> Inactive.")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        print("Inactive ---> Background.")
        exit(0)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        print("Background ---> Foreground.")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        print("Inactive ---> Active.")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        print("This app will be terminated.")
    }
}

