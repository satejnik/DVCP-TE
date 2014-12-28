/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System;
using System.ComponentModel.DataAnnotations;

namespace shared.Common
{
    public class NotNegativeAttribute : ValidationAttribute
    {
        public NotNegativeAttribute()
        {
            ErrorMessage = "Value must be equal or greater than null.";
        }

        public override bool IsValid(object value)
        {
            return Convert.ToDouble(value) > 0;
        }
    }
}
