%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
classdef XmeasController < AttackController
    
    methods
        function this = XmeasController(block)
           this = this@AttackController('xmeas', block); 
        end
        
        % conversion method
        function obj = AttackController(controller)
              obj = AttackController(controller.Type, controller.Block);
              obj.Attack = controller.Attack;
              obj.Mode = controller.Mode;
              obj.Value = controller.Value;
              obj.Start = controller.Start;
              obj.Duration = controller.Duration;
        end
    end
    
end

