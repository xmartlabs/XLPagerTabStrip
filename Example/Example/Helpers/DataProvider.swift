//  PostCell.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit

class DataProvider {
    static let sharedInstance = DataProvider()
    
    lazy var postsData: NSArray = {
        let jsonStr = "[{\"post\":{\"id\":113,\"text\":\"We're getting fifty percent of the t-shirt sales\",\"created_at\":\"2014-04-17T00:45:40.556Z\",\"user\":{\"id\":9,\"name\":\"Lisa Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Lisa_Simpsons.png\"}}},{\"post\":{\"id\":66,\"text\":\"Eep!\",\"created_at\":\"2014-04-09T21:29:59.982Z\",\"user\":{\"id\":7,\"name\":\"Bart Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Bart_Simpsons.png\"}}},{\"post\":{\"id\":42,\"text\":\"I'm not thinking straight, why did I have that wine cooler last month?\",\"created_at\":\"2014-04-09T17:58:41.704Z\",\"user\":{\"id\":5,\"name\":\"Ned Flanders\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Ned_Flanders.png\"}}},{\"post\":{\"id\":84,\"text\":\"Son, when you participate in sporting events, it's not whether you win or lose: it's how drunk you get.\",\"created_at\":\"2014-04-03T20:21:32.119Z\",\"user\":{\"id\":8,\"name\":\"Homer Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Homer_Simpsons.png\"}}},{\"post\":{\"id\":75,\"text\":\"I'm normally not a praying man, but if you're up there, please save me Superman.\",\"created_at\":\"2014-04-03T02:04:43.053Z\",\"user\":{\"id\":8,\"name\":\"Homer Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Homer_Simpsons.png\"}}},{\"post\":{\"id\":26,\"text\":\"Homer, please get rid of that pig.\",\"created_at\":\"2014-04-02T03:48:56.381Z\",\"user\":{\"id\":3,\"name\":\"Marge Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Marge_Simpsons.png\"}}},{\"post\":{\"id\":40,\"text\":\"You sold weapon-grade plutoneum to the Iraqies without a mark up.\",\"created_at\":\"2014-03-28T05:23:24.657Z\",\"user\":{\"id\":4,\"name\":\"Montgomery Burns\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Montgomery_Burns.png\"}}},{\"post\":{\"id\":28,\"text\":\"Homer, don't say that. The way I see it, if you raised three children who can knock out and hog tie a perfect stranger you must be doing something right.\",\"created_at\":\"2014-03-22T14:24:22.408Z\",\"user\":{\"id\":3,\"name\":\"Marge Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Marge_Simpsons.png\"}}},{\"post\":{\"id\":48,\"text\":\"Hi-dilly-ho, neighborinos!\",\"created_at\":\"2014-03-21T08:39:20.764Z\",\"user\":{\"id\":5,\"name\":\"Ned Flanders\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Ned_Flanders.png\"}}},{\"post\":{\"id\":78,\"text\":\"Maybe, just once, someone will call me 'Sir' without adding, 'You're making a scene.'\",\"created_at\":\"2014-03-20T02:44:28.075Z\",\"user\":{\"id\":8,\"name\":\"Homer Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Homer_Simpsons.png\"}}},{\"post\":{\"id\":33,\"text\":\"This is the type of trickery I pay you for.\",\"created_at\":\"2014-03-18T08:25:14.507Z\",\"user\":{\"id\":4,\"name\":\"Montgomery Burns\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Montgomery_Burns.png\"}}},{\"post\":{\"id\":72,\"text\":\"Oh, so they have internet on computers now!\",\"created_at\":\"2014-03-03T19:02:56.032Z\",\"user\":{\"id\":8,\"name\":\"Homer Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Homer_Simpsons.png\"}}},{\"post\":{\"id\":1,\"text\":\"You know, I do! I mean, there comes a time in a man's life when he asks himself, 'who will float my corpse down the Ganges?'\",\"created_at\":\"2014-02-24T14:09:00.912Z\",\"user\":{\"id\":1,\"name\":\"Apu Nahasapeemapetilon\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Apu_Nahasapeemapetilon.png\"}}},{\"post\":{\"id\":62,\"text\":\"Ay Caramba!\",\"created_at\":\"2014-02-18T16:38:37.958Z\",\"user\":{\"id\":7,\"name\":\"Bart Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Bart_Simpsons.png\"}}},{\"post\":{\"id\":19,\"text\":\"Throughout the ages, the finger painter, the Play-Doh sculptor, the Lincoln Logger, stood alone against the daycare teacher of her time. She did not live to earn aproval stickers, she lived for herself, that she might achieve things that are the glory of all humanity. These are my terms. I do not care to play by any others. And now, if the jury will allow me, it's naptime.\",\"created_at\":\"2014-02-16T22:11:33.236Z\",\"user\":{\"id\":2,\"name\":\"Maggie Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Maggie_Simpsons.png\"}}},{\"post\":{\"id\":76,\"text\":\"Son, if you really want something in this life, you have to work for it. Now quiet! They're about to announce the lottery numbers.\",\"created_at\":\"2014-02-16T19:09:55.062Z\",\"user\":{\"id\":8,\"name\":\"Homer Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Homer_Simpsons.png\"}}},{\"post\":{\"id\":22,\"text\":\"Somebody throw the goddamn bomb!\",\"created_at\":\"2014-02-16T13:50:25.313Z\",\"user\":{\"id\":3,\"name\":\"Marge Simpsons\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Marge_Simpsons.png\"}}},{\"post\":{\"id\":36,\"text\":\"Oh, so mother nature needs a favor? Well, maybe she should have thought of that when she was besetting us with droughts and floods and poison monkeys.\",\"created_at\":\"2014-02-13T06:51:57.549Z\",\"user\":{\"id\":4,\"name\":\"Montgomery Burns\",\"imageURL\":\"http://obscure-refuge-3149.herokuapp.com/images/Montgomery_Burns.png\"}}}]"
        let jsonData = jsonStr.data(using: String.Encoding.utf8)
        return try! JSONSerialization.jsonObject(with: jsonData!, options: []) as! NSArray
    }()
}

class NavController: UINavigationController {
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}


class TabBarController : UITabBarController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}





