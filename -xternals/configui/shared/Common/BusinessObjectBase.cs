/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;

namespace shared.Common
{
    public abstract class BusinessObjectBase : INotifyPropertyChanged, IDataErrorInfo
    {
        #region Interfaces

        #region INotifyPropertyChanged

        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged(string propertyName)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
        }

        #endregion

        #region IDataErrorInfo

        string IDataErrorInfo.Error
        {
            get { return ValidateObject(); }
        }

        string IDataErrorInfo.this[string propertyName]
        {
            get { return ValidateProperty(propertyName); }
        }

        protected string ValidateObject()
        {
            var builder = new StringBuilder();
            foreach (var property in GetType().GetProperties())
            {
                var errors = ValidateProperty(property.Name);
                if (string.IsNullOrEmpty(errors)) continue;
                var attr = property.GetCustomAttributes(false).OfType<DisplayNameAttribute>().FirstOrDefault();
                builder.Append(attr != null ? attr.DisplayName : property.Name).Append(": ").AppendLine(errors);
            }

            return builder.ToString();
        }

        protected string ValidateProperty(string propertyName)
        {
            var info = GetType().GetProperty(propertyName);
            var errorInfos = info.GetCustomAttributes(true).OfType<ValidationAttribute>()
                             .Where(attribute => !attribute.IsValid(info.GetValue(this, null)))
                             .Select(attribute => attribute.FormatErrorMessage(string.Empty))
                             .ToList();
            return errorInfos.Any() ? string.Join(Environment.NewLine, errorInfos) : string.Empty;
        }

        #endregion

        #endregion
    }
}
