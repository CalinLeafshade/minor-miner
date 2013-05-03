-- Editor platform inspector

gui = require('gui')

local pinspector = gui:new({width = 300, height = 600})
pinspector.Text = "Platform Inspector"

pinspector.mainLayout = gui.layout:new({x = 10, y = 30, fgColor = {255,0,0}}, pinspector)

pinspector.toolbarLayout = gui.layout:new({x = 0, y = 0, direction = "horizontal"}, pinspector.mainLayout)

pinspector.btnShowPlatform = gui.button:new({text = "Platforms", x=0,y=0, height = 30, width = 100}, pinspector.toolbarLayout)
pinspector.btnShowEnemy = gui.button:new({text = "Enemies", x=0,y=0, height = 30, width = 100}, pinspector.toolbarLayout)

pinspector.platformLayout = gui.layout:new({x = 0, y = 0}, pinspector.mainLayout)

pinspector.button1 = gui.button:new({x = 0, y = 0, width = 100, height = 30, text = "hello!"}, pinspector.platformLayout)
pinspector.textbox1 = gui.textbox:new({x = 0, y = 0, width = 200, height = 20, text = "textbox lol"}, pinspector.platformLayout)
--pinspector.label1 = gui.label:new({x = 0, y = 0, width = 50, height = 50, text = "This is a label"}, pinspector.platformLayout)

pinspector.enemyLayout = gui.layout:new({x = 0, y = 0, visible = false}, pinspector.mainLayout)

pinspector.button2 = gui.button:new({x = 0, y = 0, width = 100, height = 30, text = "hello!"}, pinspector.enemyLayout)
pinspector.textbox2 = gui.textbox:new({x = 0, y = 0, width = 200, height = 20, text = "textbox lol"}, pinspector.enemyLayout)
pinspector.label2 = gui.label:new({x = 0, y = 0, width = 100, height = 20, text = "This is a label"}, pinspector.enemyLayout)

function pinspector.btnShowPlatform:onClick()
	pinspector.enemyLayout.visible = false
	pinspector.platformLayout.visible = true
end

function pinspector.btnShowEnemy:onClick()
	pinspector.platformLayout.visible = false
	pinspector.enemyLayout.visible = true
end

return pinspector
