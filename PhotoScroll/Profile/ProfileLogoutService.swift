//
//  ProfileLogoutService.swift
//  PhotoScroll
//
//  Created by Капитонов Константин on 09.10.2026.
//

import Foundation
import WebKit
import SwiftKeychainWrapper
import Kingfisher

protocol ProfileLogoutServiceProtocol: AnyObject {
	func logout()
}

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
   static let shared = ProfileLogoutService()

   private init() { }

   func logout() {
	  KeychainWrapper.standard.removeAllKeys()
	  ImageCache.default.clearMemoryCache()
	  ImageCache.default.clearDiskCache()
	  cleanCookies()
   }

   private func cleanCookies() {
	  // Очищаем все куки из хранилища
	  HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
	  // Запрашиваем все данные из локального хранилища
	  WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
		 // Массив полученных записей удаляем из хранилища
		 records.forEach { record in
			WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
		 }
	  }
   }
}
