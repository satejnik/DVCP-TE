classdef Attack < handle
%ATTACK Summary of this class coming soon..
%   Detailed explanation coming soon..
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
    
    properties
        Controllers
        Xmeas
        Xmvs
    end
    
    methods
        function self = Attack()
            self.Controllers = cell(0);
        end
        
        function Add(object, controller)
           if ~isa(controller, 'Controller')
              error('input parameter must be of type Controller'); 
           end
           
           object.Controllers{end + 1} = controller;
        end
        
        function xmeas = get.Xmeas(object)
           xmeas = getControllers(object, 'xmeas');
        end
       
        function xmvs = get.Xmvs(object)
           xmvs = getControllers(object, 'xmv');
        end
        
        function Set(object)
           cellfun(@(x) x.Set(), object.Controllers);
        end
    end
    
    methods(Access = private)
        function types = getTypes(object)
            types = cellfun(@(x) {x.Type}, object.Controllers');
        end
        
        function controllers = getControllers(object, art)
           controllers = object.Controllers(strcmp(getTypes(object), art));
        end
    end
end
