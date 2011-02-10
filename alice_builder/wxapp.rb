# The script is to mimic a dashboard similar to the factory monitor watching out for 

require "rubygems"
require "wx"
include Wx 
require 'task.rb'

# require "observable"

# IDEA: add customized listeners to listen to the status of nighly build status.


# Customized panel that
# * espcially serve the alice build process
# * with factory method to create depend on a task from alice build
# * with observer listening to the build status on one PC.

# TODO: the legend of color should be closer to the UI part to be more apparent to the programmer, code's human aspect.

class TaskPanel < Panel


    # TODO: how to separate the GUI with the main task thread? 
    def initialize( parent,  
               id = -1, 
               pos = DEFAULT_POSITION, 
               size = DEFAULT_SIZE, 
               style = TAB_TRAVERSAL, 
               name = "panel", task_to_listen = nil ) 
        super(parent, id , pos, size, style, name )
        @task = task_to_listen   # TODO: decide if this is reference or shallow copy!
    end
        
    # SUG: do not add too many gadgets, it need explanations and prone to errors and doesn't help in recovering.    
    def install_ui
        @panel_sizer = BoxSizer.new(HORIZONTAL)
        self.set_sizer(@panel_sizer) 
        
        @test_label = StaticText.new(self, -1, 'My Label Text', 
                                    DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_LEFT)
        @test_label.set_background_colour(Wx::GREEN)

        # TODO: should set the background of the panel to 
        @redo_button = Button.new(self, -1, 'Redo', DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_RIGHT, DEFAULT_VALIDATOR, 'Redo')
        @recheck_button = Button.new(self, -1, 'Recheck', DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_RIGHT, DEFAULT_VALIDATOR, 'Recheck')
        @panel_sizer.add(@test_label, 50, Wx::ALL )
        @panel_sizer.add(@redo_button, 25,  Wx::RIGHT)
        @panel_sizer.add(@recheck_button, 25 , Wx::RIGHT)
    end
    
    # it is supposed to monitor task 24/7, but you know, things may change unexpected or beyond!
    def monitor_task(task)
        if task.is_a? Task  # do we have a more general design? 
            @task = task
            if @task.evaluate_result == TaskStatus::OK
                @test_label =  set_background_colour(Wx::GREEN)
            else
                @test_label =  set_background_colour(Wx::RED)
            end
        else
            puts "UI now only listens to the status of task, it's not that general for anything else."
        end
    end
end

# panel containing the button to tasks ui create/delete/suite management
class ActionPanel < Panel
   def initialize( parent,  
               id = -1, 
               pos = DEFAULT_POSITION, 
               size = DEFAULT_SIZE, 
               style = TAB_TRAVERSAL, 
               name = "panel", task_to_listen = nil ) 
        super(parent, id , pos, size, style, name )
    end
    
    def install_ui
        @panel_sizer = BoxSizer.new(HORIZONTAL)
        self.set_sizer(@panel_sizer) 
        
        # TODO: should set the background of the panel to 
        @newtask_button = Button.new(self, -1, 'New Task', DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_RIGHT, DEFAULT_VALIDATOR, 'Redo')
        #@recheck_button = Button.new(self, -1, 'Recheck', DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_RIGHT, DEFAULT_VALIDATOR, 'Recheck')
        @panel_sizer.add(@newtask_button, 25,  Wx::RIGHT)
        #@panel_sizer.add(@recheck_button, 25 , Wx::RIGHT)  
        evt_button(@newtask_button) { new_task_dialog }
    end
    
    def new_task_dialog
      dd = Dialog.new( self,  
             -1,  
             "Define a new task", 
             DEFAULT_POSITION, 
             DEFAULT_SIZE, 
             DEFAULT_DIALOG_STYLE, 
             "dialogBox")
      dd.show_modal
      # test
#      Window.new( self.parent ,  -1, 
#            DEFAULT_POSITION, 
#            DEFAULT_SIZE,  
#            0, 
#            "New Task")
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
 
         t1 = Task.new "demo task"
         t2 = Task.new "demo task 2"
         t2.set_status TaskStatus::UNAVAIL

#        t1.plan do 
#            5.times do 
#                puts "aaaaaa!"
#            end
#        end

        vbox = Wx::BoxSizer.new( Wx::VERTICAL )
 
        
        custom_panel = TaskPanel.new(f, -1 )
        custom_panel.install_ui
        custom_panel.monitor_task(t1)
        
        custom_panel2 = TaskPanel.new(f, -1 )
        custom_panel2.install_ui
        custom_panel.monitor_task(t2)
        
        action_panel = ActionPanel.new(f, -1)
        action_panel.install_ui
        
        vbox.add(custom_panel)
        vbox.add(custom_panel2)
        vbox.add(action_panel)
        
        
        # Set the window's sizer to the vbox
        f.set_sizer( vbox )
        # Make the application window the same size
        # as the sizer
        vbox.set_size_hints(f)


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
