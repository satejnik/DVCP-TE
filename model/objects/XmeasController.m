classdef XmeasController < AttackController
    %XMEASCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
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

