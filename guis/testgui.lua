--testgui

gui = require('gui')

testgui = gui:new({width = 500, height = 300})
testgui.Text = "Test gui"

testgui.button1 = gui.button:new({x = 10, y = 50, width = 100, height = 30, text = "hello!"}, testgui)
testgui.textbox1 = gui.textbox:new({x = 10, y = 90, width = 200, height = 20, text = "textbox lol"}, testgui)
testgui.label1 = gui.label:new({x = 10, y = 120, width = 50, height = 50, text = "This is a label"}, testgui)

function testgui.button1:onClick()
	testgui.textbox1.text = "hello!"
end

return testgui