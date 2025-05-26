//
//  ImageLoaderService.swift
//  Weather-forecast
//
//  Created by Vicodin on 19.05.2025.
//

import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void)
}

final class ImageLoaderService: ImageLoaderProtocol {
    
    static let shared = ImageLoaderService()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        var finalURLString = urlString
        if urlString.hasPrefix("//") {
            finalURLString = "https:" + urlString
        }
        
        if let cachedImage = cache.object(forKey: finalURLString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: finalURLString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            self?.cache.setObject(image, forKey: finalURLString as NSString)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }
}
