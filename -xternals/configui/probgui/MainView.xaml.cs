/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System.IO;
using System.Windows;
using System.Windows.Input;
using Microsoft.Win32;
using probgui.Model;
using shared.Common;
using shared.Model;

namespace probgui
{
    public partial class MainView
    {
        #region Constructs

        public MainView()
        {
            DataContext = new ProbModel();
            InitializeComponent();
        }

        #endregion

        #region Properties

        internal ProbModel Model
        {
            get { return (ProbModel)DataContext; }
        }

        #endregion

        #region Events

        public event ScriptEventHandler ScriptEvent;

        private void OnScriptEvent(IMatlabScript scriptable)
        {
            if (ScriptEvent != null)
                ScriptEvent(this, new ScriptEventArgs(scriptable.ToScript()));
        }

        private void OnScriptEvent(string script)
        {
            if (ScriptEvent != null)
                ScriptEvent(this, new ScriptEventArgs(script));
        }

        #endregion

        #region Handlers

        private void ExitButton_OnClick(object sender, ExecutedRoutedEventArgs e)
        {
            Close();
        }

        private void CopyButton_OnClick(object sender, ExecutedRoutedEventArgs e)
        {
            Clipboard.SetData(DataFormats.Text, ((IMatlabScript)Model).ToScript());
        }

        private void RunButton_OnClick(object sender, ExecutedRoutedEventArgs e)
        {
            OnScriptEvent(((IMatlabScript)Model).ToScript());
        }

        #endregion

        #region Helpers

        void CanExecute(object sender, CanExecuteRoutedEventArgs args)
        {
            args.CanExecute = Model.IsValid;
        }

        #endregion
    }
}
