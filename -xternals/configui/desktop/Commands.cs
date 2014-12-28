/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System.Windows.Input;

namespace configui
{
    public static class Commands
    {
        public static readonly RoutedUICommand Reset = new RoutedUICommand
                (
                        "Reset",
                        "Reset",
                        typeof(Commands),
                        new InputGestureCollection
                        {
                                        new KeyGesture(Key.R, ModifierKeys.Control)
                                }
                );

        public static readonly RoutedUICommand Set = new RoutedUICommand
                (
                        "Set",
                        "Set",
                        typeof(Commands),
                        new InputGestureCollection
                        {
                                        new KeyGesture(Key.T, ModifierKeys.Control)
                                }
                );

        public static readonly RoutedUICommand SaveAs = new RoutedUICommand
                (
                        "SaveAs",
                        "SaveAs",
                        typeof(Commands),
                        new InputGestureCollection
                        {
                                        new KeyGesture(Key.S, ModifierKeys.Control)
                                }
                );

        public static readonly RoutedUICommand Run = new RoutedUICommand
                (
                        "Run",
                        "Run",
                        typeof(Commands),
                        new InputGestureCollection
                        {
                                        new KeyGesture(Key.N, ModifierKeys.Control)
                                }
                );

        public static readonly RoutedUICommand Default = new RoutedUICommand
                (
                        "Default",
                        "Default",
                        typeof(Commands),
                        new InputGestureCollection
                        {
                                        new KeyGesture(Key.D, ModifierKeys.Control)
                                }
                );

        public static readonly RoutedUICommand Exit = new RoutedUICommand
                (
                        "Exit",
                        "Exit",
                        typeof(Commands),
                        new InputGestureCollection
                        {
                                        new KeyGesture(Key.E, ModifierKeys.Control)
                                }
                );
    }
}
