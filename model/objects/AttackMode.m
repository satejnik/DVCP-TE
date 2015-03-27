%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
classdef AttackMode
    
    properties
        String
        Value
    end
    
    methods
        function this = AttackMode(string, value)
            this.String = string;
            this.Value = value;
        end
    end
    
    methods(Static)
        function modes = Modes()
            enums = enumeration('AttackMode');
            modes = {enums.String}';
        end
        
        function mode = FromValue(value)
            switch value
                case 1
                    mode = AttackMode.NONE;
                case 2
                    mode = AttackMode.STEP;
                case 3
                    mode = AttackMode.INTERVAL;
                case 4
                    mode = AttackMode.PERIODIC;
                otherwise
                    error('AttackMode:FromValue', 'Bad value (%f).', value);
            end
        end
    end
    
    enumeration
        NONE('No attack', 1)
        STEP('Step attack', 2)
        INTERVAL('Interval attack', 3)
        PERIODIC('Periodical attack', 4)
    end
end



