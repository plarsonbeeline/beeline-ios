//
//  TournamentTableViewCell.swift
//  Tournaments
//
//  Created by Phil Larson on 1/23/18.
//  Copyright © 2018 Phil Larson. All rights reserved.
//

import UIKit

class TournamentTableViewCell: UITableViewCell {

    // MARK: - Initialize

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
