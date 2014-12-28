/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System.Windows.Input;

namespace probgui
{
    public static class Commands
    {
        public static readonly RoutedUICommand CopyToClipboard = new RoutedUICommand
                (
                        "CopyToClipboard",
                        "CopyToClipboard",
                        typeof(Commands),
                        new InputGestureCollection
                        {
                                        new KeyGesture(Key.C, ModifierKeys.Control)
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
