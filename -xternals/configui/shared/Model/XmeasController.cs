/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

namespace shared.Model
{
    public sealed class XmeasController : Controller
    {
        #region Constructs

        public XmeasController(int number)
            :base("xmeas", number)
        {
            
        }

        #endregion
    }
}
