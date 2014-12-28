/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System;
using System.ComponentModel;
using System.Linq;
using System.Windows.Markup;

namespace shared.Common
{
    public class DisplayNameExtension : MarkupExtension
    {
        public Type Type { get; set; }

        public string PropertyName { get; set; }

        public DisplayNameExtension() { }

        public DisplayNameExtension(string propertyName)
        {
            PropertyName = propertyName;
        }

        public override object ProvideValue(IServiceProvider serviceProvider)
        {
            var attrs = Type.GetProperty(PropertyName).GetCustomAttributes(typeof(DisplayNameAttribute), false);
            // ReSharper disable once PossibleNullReferenceException
            return attrs.Any() ? (attrs.First() as DisplayNameAttribute).DisplayName: PropertyName;
        }
    }
}
