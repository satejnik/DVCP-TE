%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
classdef AttackType
    
    properties
        String
        Value
    end
    
    methods
        function self = AttackType(string, value)
            self.String = string;
            self.Value = value;
        end
    end
    
    methods(Static)
        function types = Types()
            enums = enumeration('AttackType');
            types = {enums.String}';
        end
        
        function type = FromValue(value)
            switch value
                case 1
                    type = AttackType.INTEGRITY;
                case 2
                    type = AttackType.DOS;
                case 3
                    type = AttackType.CUSTOM;
                otherwise
                    error('AttackType:FromValue', 'Bad value (%f).', value);
            end
        end
    end
    
    enumeration
        INTEGRITY('Integrity attack', 1)
        DOS('DOS attack', 2)
        CUSTOM('Custom attack', 3)
    end
end