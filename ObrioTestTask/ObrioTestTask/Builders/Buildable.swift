//
//  Buildable.swift
//  ObrioTestTask
//
//  Created by Serhii on 24.09.2025.
//


import UIKit

protocol Buildable { associatedtype Product; func build() -> Product }
