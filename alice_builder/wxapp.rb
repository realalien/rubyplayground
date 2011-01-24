# The script is to mimic a dashboard similar to the factory monitor watching out for 

require "rubygems"
require "wx"
include Wx 


require "observable"

# IDEA: add customized listeners to listen to the status of nighly build status.


# Customized panel that
# * espcially serve the alice build process
# * with factory method to create depend on a task from alice build
# * with observer listening to the build status on one PC.
class TaskPanel < Panel


    # TODO: how to separate the GUI with the main task thread? 
    def initialize( parent,  id, 
               pos = DEFAULT_POSITION, 
               size = DEFAULT_SIZE, 
               style = TAB_TRAVERSAL, 
               name = "panel", 
               task_to_listen = nil )
        super.intialize(parent, id, pos, size, style, name )
        
        panel_sizer = BoxSizer.new(HORIZONTAL)
        status_panel.set_sizer(panel_sizer)
        
        test_label = StaticText.new(status_panel, -1, 'My Label Text', 
                                    DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_LEFT)
        test_label.set_background_colour(Wx::GREEN)

        # TODO: should set the background of the panel to 
        redo_button = Button.new(status_panel, -1, 'Redo', DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_RIGHT, DEFAULT_VALIDATOR, 'Redo')
        recheck_button = Button.new(status_panel, -1, 'Recheck', DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_RIGHT, DEFAULT_VALIDATOR, 'Recheck')
        panel_sizer.add(test_label, 50, Wx::ALL )
        panel_sizer.add(redo_button, 25,  Wx::RIGHT)
        panel_sizer.add(recheck_button, 25 , Wx::RIGHT)
    end
    
        
        
    
    
    
end



class MinimalApp < App
    def on_init
        f = Frame.new(nil, -1, "The Bare Minimum")
        
        # the panel containing all sub  panels
#        dashboard = Panel.new(f)
#        dashboard_sizer = BoxSizer.new(VERTICAL)
#        dashboard.set_sizer(dashboard_sizer)
        
        
        # TODO: question, why the two panel adding in, those panels are sequeezed into small area? 
 
        custom_panel = TaskPanel.new(f)
        
#        status_panel = Panel.new(f)
#        status_panel_sizer = BoxSizer.new(HORIZONTAL)
#        status_panel.set_sizer(status_panel_sizer)
#       
#        
#        # TODO: here I may going to added customized the control to allow the status change listening to outside
#        test_label = StaticText.new(status_panel, -1, 'My Label Text', 
#                                    DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_LEFT)
#        test_label.set_background_colour(Wx::GREEN)
#
#        # TODO: should set the background of the panel to 
#        redo_button = Button.new(status_panel, -1, 'Redo', DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_RIGHT, DEFAULT_VALIDATOR, 'Redo')
#        recheck_button = Button.new(status_panel, -1, 'Recheck', DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_RIGHT, DEFAULT_VALIDATOR, 'Recheck')
#        status_panel_sizer.add(test_label, 50, Wx::ALL )
#        status_panel_sizer.add(redo_button, 25,  Wx::RIGHT)
#        status_panel_sizer.add(recheck_button, 25 , Wx::RIGHT)
       
       
       
#        dashboard_sizer.add(status_panel)
        

        f.show()
    end
end
MinimalApp.new.main_loop

#if __FILE__ == $0
#    
#end