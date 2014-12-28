/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System;
using System.Linq;

namespace shared.Common
{
    public static class EnumExtensions
    {
        public static string ToStringValue(this Enum source)
        {
            var attribute = source.GetType()
                .GetField(source.ToString())
                .GetCustomAttributes(typeof(StringValueAttribute), false)
                .FirstOrDefault();

            return attribute == null ? source.ToString() : ((StringValueAttribute)attribute).Value;
        }

        public static string[] GetStringValues(Type enumType)
        {
            if (!enumType.IsEnum) throw new ArgumentException("Input parameter must be an enumeration type.");
            var attrs = enumType.GetFields().Skip(1)
                .Select(field => field.GetCustomAttributes(typeof(StringValueAttribute), false)
                    .FirstOrDefault()).ToArray();
            return attrs.Contains(null) ? 
                        Enum.GetNames(enumType) : 
                        attrs.Select(attr => ((StringValueAttribute)attr).Value).ToArray();
        }
    }
}
