//
//  ViewController.swift
//  WebKitMainActorCrash
//
//  Created by Robin Kunde on 3/27/25.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Task {
            await Self.performTest()
//            await performTestWithHelper()
        }
    }

    nonisolated
    static func performTest() async {
        for x in 1...100 {
            let cookies = generateBunchOfCookies(cookieCount: 1000, prefix: "\(x)")

            let websiteDataStore = await WKWebsiteDataStore.nonPersistent()
            let cookieStore = await websiteDataStore.httpCookieStore
            for cookie in cookies {
                await cookieStore.setCookie(cookie)
            }
        }

        print("done")
    }

    nonisolated
    func performTestWithHelper() async {
        for outer in 1...100 {
            let cookies = Self.generateBunchOfCookies(cookieCount: 1000, prefix: "\(outer)")

            let _ = await HTTPCookieUtility.createWebsiteDataStore(httpCookies: cookies)
        }

        print("done")
    }

    nonisolated
    private static func generateBunchOfCookies(cookieCount: Int, prefix: String) -> [HTTPCookie] {
        var httpCookies = [HTTPCookie]()

        for index in 1...cookieCount {
            let properties: [HTTPCookiePropertyKey: Any] = [.domain: "www.example.com", .path: "/", .name: "\(prefix)-name-\(index)", .value: "\(prefix)-value-\(index)"]
            let httpCookie = HTTPCookie(properties: properties)!

            httpCookies.append(httpCookie)
        }

        return httpCookies
    }
}

public struct HTTPCookieUtility {
    public static func createWebsiteDataStore(httpCookies: [HTTPCookie]) async -> WKWebsiteDataStore {
        let websiteDataStore = await WKWebsiteDataStore.nonPersistent()

        let cookieStore = await websiteDataStore.httpCookieStore
        for cookie in httpCookies {
            await cookieStore.setCookie(cookie)
        }

        return websiteDataStore
    }
}
