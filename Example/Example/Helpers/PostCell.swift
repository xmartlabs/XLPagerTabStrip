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

import UIKit

class PostCell: UITableViewCell {
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var postName: UILabel!
    @IBOutlet weak var postText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = 10.0
    }
    
    
    func configureWithData(_ data: NSDictionary){
        if let post = data["post"] as? NSDictionary, let user = post["user"] as? NSDictionary {
            postName.text = user["name"] as? String
            postText.text = post["text"] as? String
            userImage.image = UIImage(named: postName.text!.replacingOccurrences(of: " ", with: "_"))
        }
    }
    
    
    func changeStylToBlack(){
        userImage?.layer.cornerRadius = 30.0
        postText.text = nil
        postName.font = UIFont(name: "HelveticaNeue-Light", size:18) ?? .systemFont(ofSize: 18)
        postName.textColor = .white
        backgroundColor = UIColor(red: 15/255.0, green: 16/255.0, blue: 16/255.0, alpha: 1.0)
    }
}
