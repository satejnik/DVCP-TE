/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System.IO;
using System.Windows.Input;
using Microsoft.Win32;
using shared.Common;
using shared.Model;

namespace configui
{
    public partial class MainView
    {
        #region Constructs

        public MainView()
        {
            DataContext = new UIModel();
            InitializeComponent();
        }

        #endregion

        #region Properties

        internal UIModel Model
        {
            get { return (UIModel) DataContext; }
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

        private void SaveButton_OnClick(object sender, ExecutedRoutedEventArgs e)
        {
            var saveFileDialog = new SaveFileDialog
            {
                Filter = "MATLAB Code files (*.m)|*.m"
            };
            if (saveFileDialog.ShowDialog() == true)
                File.WriteAllText(saveFileDialog.FileName, ((IMatlabScript)Model).ToScript());
        }

        private void SetButton_OnClick(object sender, ExecutedRoutedEventArgs e)
        {
            OnScriptEvent(Model);
        }

        private void DefaultButton_OnClick(object sender, ExecutedRoutedEventArgs e)
        {
            Model.Reset();
        }

        private void ResetButton_OnClick(object sender, ExecutedRoutedEventArgs e)
        {
            Model.Reset();
            OnScriptEvent(Model);
        }

        private void RunButton_OnClick(object sender, ExecutedRoutedEventArgs e)
        {
            OnScriptEvent(UIModel.RunSimCommand());
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
