/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System;
using System.Globalization;
using System.Text;
using shared.Common;

namespace shared.Model
{
    public class UIModel : IMatlabScript
    {
        #region Constructs

        public UIModel()
        {
            var xmeasIndexes = new[] {1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 17, 31, 40};
            Xmeas = new ControllerCollection<XmeasController>();
            for(var index = 0; index < 16; index++)
                Xmeas.Add(new XmeasController(xmeasIndexes[index]));

            Xmv = new ControllerCollection<XmvController>();
            for (var index = 1; index < 13; index++)
                Xmv.Add(new XmvController(index));
        }

        #endregion

        #region Properties

        public ControllerCollection<XmeasController> Xmeas { get; private set; }

        public ControllerCollection<XmvController> Xmv { get; private set; }

        public bool IsValid
        {
            get { return Xmeas.Validate() && Xmv.Validate(); }
        }

        #endregion

        #region Methods

        //public static string ModelRoot
        //{
        //    get { return "gcr"; }
        //}

        //public static string ControllerPath(Controller controller)
        //{
        //    var number = controller.Number;
        //    var name = controller.Name.Substring(0,
        //                controller.Name.IndexOf(
        //                number.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal));

        //    return string.Join("/", new[] { ModelRoot,
        //                                    "TE Plant",
        //                                    name + " atk block",
        //                                    controller.Name + " attack controller"});
        //}

        public static string SetParameterCommand(Controller controller, ControllerProperties property, object value)
        {
            var number = controller.Number;
            var name = controller.Name.Substring(0,
                        controller.Name.IndexOf(
                        number.ToString(CultureInfo.InvariantCulture), StringComparison.Ordinal));
            return string.Format("set_{0}_ctrl_param({1}, {2}, {3});", name, number, property.ToStringValue(), value);
        }

        public static string RunSimCommand()
        {
            return "evalin('base', 'sim(model);');";
        }

        public void Reset()
        {
            Xmeas.Reset();
            Xmv.Reset();
        }

        #endregion

        #region Interfaces

        #region IMatlabScript

        string IMatlabScript.ToScript()
        {
            var builder = new StringBuilder();
            builder.Append(((IMatlabScript)Xmeas).ToScript());
            builder.Append(((IMatlabScript)Xmv).ToScript());
            return builder.ToString();
        }

        #endregion

        #endregion
    }
}
