/*	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */

using System;
using shared.Model;

namespace shared.Common
{
    public class ScriptEventArgs : EventArgs
    {
        public ScriptEventArgs(string script)
        {
            Script = script;
        }

        public ScriptEventArgs(IMatlabScript script)
        {
            Script = script.ToScript();
        }

        public string Script { get; set; }
    }
}
