/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

namespace configui.Model
{
    internal static class Matlab
    {
        public static string CommentLine(string line)
        {
            return "% " + line;
        }

        public static string BlockLine()
        {
            return "%%";
        }

        public static string BlockLine(string line)
        {
            return BlockLine() + " " + line;
        }
    }
}
