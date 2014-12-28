/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Text;
using configui.Model;
using shared.Common;

namespace shared.Model
{
    public class ControllerCollection<T> : ObservableCollection<T>, IMatlabScript, IDataErrorInfo
        where T : Controller
    {
        #region Interfaces

        #region IMatlabScript

        string IMatlabScript.ToScript()
        {
            var builder = new StringBuilder();
            builder.AppendLine(Matlab.BlockLine("Setting " +
                typeof(T).Name.Substring(0, typeof(T).Name
                .IndexOf("Controller", System.StringComparison.Ordinal)).ToLower()) +
                " controllers parameters");
            builder.AppendLine();
            foreach (var controller in this)
            {
                builder.AppendLine(((IMatlabScript)controller).ToScript());
            }
            return builder.ToString();
        }

        #endregion

        #region IDataErrorInfo

        string IDataErrorInfo.Error
        {
            get
            {
                return this.Any(item => !item.Validate()) ? "Collection contains not valid elements." : string.Empty;
            }
        }

        string IDataErrorInfo.this[string columnName]
        {
            get { return string.Empty; }
        }

        #endregion

        #endregion

        #region Methods

        public void Reset()
        {
            foreach (var controller in this)
                controller.Reset();
        }

        #endregion
    }
}
