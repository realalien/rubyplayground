#encoding: UTF-8


# Coded Notes on 'The design of future things', Don Norman
# Detailing the following questions


Context "what's the obvious software feedback if something goes wrong or it can't handle? Some physical sympton like 'straightened, tense, beeping or sound feedback? " do
	listing do 
			[""] //TODO
	end

end



Context "software supportive functionalities and how it is implemented" do
	eg "experimenting with partial correction"
	eg "signaling users"
	eg "does give users any say in ineraction"
	eg "let user know which system can be trusted via demos"
  eg "how to handle if things does not go as planned."
end


Context "intelligence" do
	listing do 
		["initiatives", "intelligence", "emotion", "personalities"]
  end
  eg "Collaboration via synchronizing user's acitivities, as well as explaining and giving reasons. Through experience and understanding"

  eg "Socrates: a technology that gives no opportunities for discussion, explanation, or debate is poor tech, the PROCESS of making a decision is often more important than the decision itself."

  eg "know why system thinks in one way"

	listing do 
		["safety", "convenience", "accuracy"]
	end
    
    eg "Statistical regularity can be useful. The widget doesn't take any action. Rather, it gets ready to act, projecting a likey set of alternative actions on the counter so that if by chance one of them is what you are planning to do, you only have to touch and indicate yes."

end


Context "interaction consideration between machine and human" do
	eg "change the way we interact with our machines to take better advantage of their strengths and virtues, while at the same time eleminating their annoying and sometimes dangerous actions"

  eg "whenever a task is only partially automated, it is essential that each party, human and machine, know what the other is doing and what is intended."

	eg "successful dialogue requires shared knowledge and experiences. It requires appreciation of the env and context, of the history leading up to the moment, and of the many differing goals and motives of the people involved."

	eg "the propery way to provide for smooth interaction between people and intelligent device is to enhance the coordination and cooperation of both parties, people and machines"

	eg "must design our tech for the way people actually behave, not the way we would like them to behave"

	eg "determine the appropriate response to something unexpected? When this happens to a person, we can expect creative, imagninative problem solving"

	eg "understand the goals and motives of the people with whom they must interact, the special circustances that invariably surround any set of activities."

  eg "social skills, creativity, imagination, empathy"

	eg "it doesn't really matter whether the machine or the person is correct: it is the mismatch that matters, for this is what gives rise to aggravation, frustration, and in some cases, damage or injury"

	eg "let interested parties to know why the machine is doing this "
  
  
    test_case ["positive", "pleasurable", "effective"] # like artists with tools

    test_case ["comfortable", "friendly", "aethetically pleasing", "lighting", "calm", "restful"]


    eg "ambient intelligence, with the goal to create smart environments that react in an attentive, adaptive and proactive way to the presenses and acitivities of humans, in ordr to provide the services taht inhabitants of these environments request or are presumed to need."
    
    
    eg "need to understand the context, the reasoning behind the action. For some unsual actions."

end


Context "software features to be implemented" do
  eg "ask for details or seek some modification, better conversation to the lists for users who are not so knowledgeable!" 
end

Context "in the near future" do 
	eg "monitor user eating, reading, music and tel preferences, watch where you drive, alerting insurance company, rental agency or even police, system makes gross assumptions about your intentions from a limited sample of your behaviors
end


Research "the whole process manipulation" do
   user_case "What do you call it when people ask their phone “What’s the best used car?”,  and get all the way to purchase decision just by talking?"
   
end

Study "sci-fi use cases study" do
    eg "Star Trek"
    eg "Joseph Weizenbaum’s 1966 program ELIZA " do
        
    end
    
end



xf Notes:
*  actual: "我1885点怎么样" （datetime, 01月26日，5:00）
   expect:  "（俏江南）1885店怎么样"





* actual "请帮我找皇甫去的餐厅"(xf)
  expect: "请帮我找黄浦区的餐厅"



* actual:  "新视角餐厅酒廊" (no object.name)
  expect:  "新视角餐厅酒廊"( as object, distinguished with "新视角餐厅")

