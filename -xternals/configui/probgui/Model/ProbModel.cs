/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System.ComponentModel;
using System.Text;
using shared.Common;
using shared.Model;

namespace probgui.Model
{
    internal class ProbModel : BusinessObjectBase, IMatlabScript
    {
        #region Properties

        [DisplayName]
        public ControllerTypes Type { get; set; }

        private int number;

        [DisplayName("Controller Block (Number)")]
        [NotNegative]
        public int Number
        {

            get { return number; }
            set
            {
                if (number == value) return;
                number = value;
                OnPropertyChanged("Number");
            }
        }

        private int start;

        [DisplayName("Start Interval")]
        [NotNegative]
        public int Start
        {

            get { return start; }
            set
            {
                if (start == value) return;
                start = value;
                OnPropertyChanged("Start");
            }
        }

        private int end;

        [DisplayName("End Interval")]
        [NotNegative]
        public int End
        {

            get { return end; }
            set
            {
                if (end == value) return;
                end = value;
                OnPropertyChanged("End");
            }
        }

        private int step;

        [DisplayName("Step")]
        [NotNegative]
        public int Step
        {

            get { return step; }
            set
            {
                if (step == value) return;
                step = value;
                OnPropertyChanged("Step");
            }
        }

        private int iterations;

        [NotNegative]
        public int Iterations
        {
            get { return iterations; }
            set
            {
                if (iterations == value) return;
                iterations = value;
                OnPropertyChanged("Iterations");
            }
        }

        public bool IsValid
        {
            get { return string.IsNullOrEmpty(((IDataErrorInfo)this).Error); }
        }

        public string Error
        {
            get { return ((IDataErrorInfo)this).Error; }
        }

        #endregion

        #region Interfaces

        #region IMatlabScript

        string IMatlabScript.ToScript()
        {
            var builder = new StringBuilder();
            builder.AppendFormat("evalin('base', 'plotSuccessAttackProbability(''{0}'', {1}, {2}, {3}, {4}, {5});');",
                                Type.ToStringValue(), Number, Start, End, Step, Iterations);
            return builder.ToString();
        }

        #endregion

        #endregion

        #region Methods

        protected override void OnPropertyChanged(string propertyName)
        {
            base.OnPropertyChanged(propertyName);
            base.OnPropertyChanged("IsValid");
            base.OnPropertyChanged("Error");
        }

        #endregion
    }
}
