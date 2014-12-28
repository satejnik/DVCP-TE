/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System.ComponentModel;

namespace shared.Common
{
    public static class ObjectExtensions
    {
        public static bool Validate(this object source)
        {
            if (source is IDataErrorInfo)
                return string.IsNullOrEmpty(((IDataErrorInfo)source).Error);
            return true;
        }
    }
}
