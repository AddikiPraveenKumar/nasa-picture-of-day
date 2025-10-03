//
//  ImageLoaderProtocol.swift
//  NASAAPODApp
//
//  Created by Praveen UK on 01/10/2025.
//
import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: URL) async -> UIImage?
}
