/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using shared.Common;

namespace shared.Model
{
    public enum ControllerProperties
    {
        [StringValue("ControllerProperties.ATTACK.Value")]
        Attack,
        [StringValue("ControllerProperties.MODE.Value")]
        AttackMode,
        [StringValue("ControllerProperties.VALUE.Value")]
        IntegrityAtackValue,
        [StringValue("ControllerProperties.START.Value")]
        Start,
        [StringValue("ControllerProperties.DURATION.Value")]
        Duration
    }
}
