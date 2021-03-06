﻿/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using shared.Common;

namespace shared.Model
{
    public enum Attack
    {
        [StringValue("AttackType.INTEGRITY.String")]
        Intergrity,
        [StringValue("AttackType.DOS.String")]
        DOS
    }
}
